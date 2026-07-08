#!/usr/bin/env python3
"""
verify_public.py — Use public SDK frameworks as groundtruth to verify swift-interface-gen.

For each public framework that has both a .tbd and a .swiftinterface, this script:
  1. Runs swift-interface-gen on the .tbd to produce a GeneratedInterface.swift
  2. Compiles a first-pass dylib (no exports list) and counts missing symbols
  3. Runs the full pipeline (stubs + exports list) and counts final missing symbols
  4. Parses Apple's real .swiftinterface and our generated interface
  5. Computes declaration coverage (type + member match ratios)
  6. Writes results to public_fw_results.json and prints a summary table

Usage:
  python3 verify_public.py [--frameworks F1,F2,...] [--baseline] [--jobs N]

  --frameworks   Comma-separated list of framework names to test (default: curated subset)
  --baseline     Write results to public_fw_baseline.json for future regression comparison
  --jobs N       Parallel workers (default: 4)
  --all          Test all 196 frameworks (slow)
"""

import os
import sys
import re
import json
import shutil
import argparse
import subprocess
import tempfile
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

SDK_ROOT = subprocess.check_output(["xcrun", "--show-sdk-path"]).decode().strip()
FRAMEWORKS_DIR = f"{SDK_ROOT}/System/Library/Frameworks"
SCRIPT_DIR = Path(__file__).parent

# Curated subset: pure-Swift, well-bounded, representative variety
CURATED = [
    "Combine",
    "Network",
    "MetricKit",
    "CoreML",
    "TabularData",
    "Charts",
    "SwiftData",
    "StoreKit",
    "CreateML",
    "Translation",
    "CryptoKit",
    "TipKit",
    "HealthKit",
    "GameKit",
    "SoundAnalysis",
    "Speech",
    "Vision",
    "NearbyInteraction",
]

SYSTEM_MODULES = {
    "Swift", "Foundation", "ObjectiveC", "os", "Dispatch", "Metal", "CoreGraphics",
    "CoreVideo", "CoreMedia", "IOSurface", "UniformTypeIdentifiers", "XPC",
    "Synchronization", "MetricKit", "Combine", "CoreAI", "CoreFoundation",
}

# ---------------------------------------------------------------------------
# Framework discovery
# ---------------------------------------------------------------------------

def find_public_frameworks():
    """Return dict of name -> {tbd, swiftinterface} for all qualifying public frameworks."""
    results = {}
    for fw_dir in Path(FRAMEWORKS_DIR).glob("*.framework"):
        name = fw_dir.name[:-len(".framework")]
        # Find tbd
        tbd = next((str(p) for p in [
            fw_dir / f"{name}.tbd",
            fw_dir / "Versions" / "A" / f"{name}.tbd",
        ] if p.exists()), None)
        if not tbd:
            continue
        # Find arm64*-apple-macos.swiftinterface (arm64 or arm64e)
        ifaces = list(fw_dir.rglob("arm64*-apple-macos.swiftinterface"))
        if not ifaces:
            continue
        # Prefer arm64-apple-macos over arm64e if both exist
        iface = next((str(i) for i in ifaces if "arm64e" not in str(i)), str(ifaces[0]))
        results[name] = {"tbd": tbd, "swiftinterface": iface}
    return results

# ---------------------------------------------------------------------------
# Declaration extraction from swiftinterface
# ---------------------------------------------------------------------------

def extract_declarations(swift_text):
    """
    Extract top-level and nested public declaration names from Swift source text.
    Returns (types: set[str], members: set[str]).
    types  = "TypeName" for top-level, "Outer.Inner" for nested
    members = "TypeName.memberName" or "TypeName.init(...)" etc.
    """
    types = set()
    members = set()

    # Strip comments
    swift_text = re.sub(r'//[^\n]*', '', swift_text)
    swift_text = re.sub(r'/\*.*?\*/', '', swift_text, flags=re.DOTALL)

    # Match public type declarations (struct/class/enum/protocol/extension/typealias)
    type_pattern = re.compile(
        r'(?:^|\n)\s*(?:@\S+\s+)*(?:public|open)\s+'
        r'(?:final\s+)?(?:struct|class|enum|protocol|actor|extension)\s+'
        r'([A-Za-z_][A-Za-z0-9_.<>, ]*?)(?:\s*[:{<(]|\s*$)',
        re.MULTILINE
    )
    for m in type_pattern.finditer(swift_text):
        raw = m.group(1).strip()
        # Strip generic params for name only
        name = re.sub(r'<.*', '', raw).strip()
        if name and not name.startswith('_'):
            types.add(name)

    # Match public member declarations (func/var/let/init/subscript/case)
    member_pattern = re.compile(
        r'(?:^|\n)\s{4,}(?:@\S+\s+)*(?:public|open|internal\(set\))\s+'
        r'(?:static\s+|class\s+|final\s+|override\s+|mutating\s+|nonmutating\s+)*'
        r'(?:func|var|let|init|subscript|case)\s+'
        r'([A-Za-z_`][A-Za-z0-9_`]*)',
        re.MULTILINE
    )
    for m in member_pattern.finditer(swift_text):
        members.add(m.group(1).strip('`'))

    return types, members

# ---------------------------------------------------------------------------
# Symbol counting via --compare
# ---------------------------------------------------------------------------

def count_symbols_in_exports(exports_file):
    """Count lines in an exports file (each line = one symbol)."""
    try:
        with open(exports_file) as f:
            return sum(1 for l in f if l.strip())
    except FileNotFoundError:
        return 0

def run_compare(exports_file, dylib_path, stubs_out):
    """Run swift-interface-gen --compare and return (missing_count, extra_count)."""
    result = subprocess.run(
        [str(SCRIPT_DIR / "swift-interface-gen"), "--compare",
         exports_file, dylib_path, stubs_out],
        capture_output=True, text=True
    )
    out = result.stdout + result.stderr
    missing = 0
    extra = 0
    for line in out.splitlines():
        m = re.match(r'--- Missing Symbols.*Count:\s*(\d+)', line)
        if m:
            missing = int(m.group(1))
        m = re.match(r'--- Extra Symbols.*Count:\s*(\d+)', line)
        if m:
            extra = int(m.group(1))
        # Also parse inline "Count:" lines
        m = re.match(r'Count:\s*(\d+)', line.strip())
        if m and missing == 0:
            missing = int(m.group(1))
            break
    # Parse from the "Generated N stubs" line
    gen_match = re.search(r'Generated (\d+) stubs', out)
    if gen_match:
        missing = int(gen_match.group(1))
    return missing, extra

# ---------------------------------------------------------------------------
# Per-framework test
# ---------------------------------------------------------------------------

def test_framework(name, tbd, swiftinterface_path, work_dir):
    """
    Run the full verification pipeline for one framework.
    Returns a result dict.
    """
    result = {
        "framework": name,
        "tbd_symbols": 0,
        "first_pass_stubs": -1,
        "final_missing": -1,
        "type_coverage": -1.0,
        "member_coverage": -1.0,
        "apple_types": 0,
        "apple_members": 0,
        "matched_types": 0,
        "matched_members": 0,
        "error": None,
    }

    gen_iface = os.path.join(work_dir, f"{name}Interface.swift")
    exports_file = os.path.join(work_dir, f"{name}_exports.txt")
    first_pass_dylib = os.path.join(work_dir, f"{name}_fp.dylib")
    final_dylib = os.path.join(work_dir, f"{name}_final.dylib")
    stubs_s = os.path.join(work_dir, f"stubs_{name}.s")
    stubs_o = os.path.join(work_dir, f"stubs_{name}.o")
    install_name = f"/System/Library/Frameworks/{name}.framework/Versions/A/{name}"

    local_fw = os.path.join(work_dir, "LocalFrameworks")
    os.makedirs(local_fw, exist_ok=True)

    def run(cmd, **kwargs):
        return subprocess.run(cmd, capture_output=True, text=True, **kwargs)

    try:
        # 1. Generate interface from TBD
        r = run([str(SCRIPT_DIR / "swift-interface-gen"), tbd])
        if r.returncode != 0:
            result["error"] = f"generate failed: {r.stderr[:300]}"
            return result
        with open(gen_iface, "w") as f:
            f.write(r.stdout)

        # Count TBD symbols (from exports file written by generator)
        local_exports = f"{name}_exports.txt"
        if os.path.exists(local_exports):
            result["tbd_symbols"] = count_symbols_in_exports(local_exports)
            shutil.copy(local_exports, exports_file)
            os.remove(local_exports)
        else:
            result["error"] = "no exports file generated"
            return result

        # 2. Compile first-pass dylib (no exports list, undefined=dynamic_lookup)
        compile_cmd = [
            "swiftc", "-emit-library", "-o", first_pass_dylib,
            gen_iface,
            "-enable-library-evolution", "-module-name", name,
            "-F", local_fw, "-sdk", SDK_ROOT,
            "-language-mode", "6",
            "-Xlinker", "-undefined", "-Xlinker", "dynamic_lookup",
            "-Xlinker", "-not_for_dyld_shared_cache",
            "-Xlinker", "-install_name", "-Xlinker", install_name,
            "-enable-experimental-feature", "NonescapableTypes",
            "-enable-experimental-feature", "Lifetimes",
        ]
        r = run(compile_cmd)
        if r.returncode != 0 or not os.path.exists(first_pass_dylib):
            first_err = next((l for l in r.stderr.splitlines() if 'error:' in l and 'note:' not in l), r.stderr[:200])
            result["error"] = f"first-pass compile failed: {first_err[:200]}"
            return result

        # 3. Count first-pass missing symbols
        first_missing, _ = run_compare(exports_file, first_pass_dylib, stubs_s)
        result["first_pass_stubs"] = first_missing

        # 4. Assemble stubs and build final dylib
        if first_missing > 0 and os.path.exists(stubs_s) and os.path.getsize(stubs_s) > 10:
            r = run(["clang", "-c", stubs_s, "-o", stubs_o])
            if r.returncode != 0:
                result["error"] = f"assemble stubs failed: {r.stderr[:200]}"
                return result
            extra_objs = [stubs_o]
        else:
            extra_objs = []

        final_cmd = [
            "swiftc", "-emit-library", "-o", final_dylib,
            gen_iface,
            "-enable-library-evolution", "-module-name", name,
            "-F", local_fw, "-sdk", SDK_ROOT,
            "-language-mode", "6",
            "-Xlinker", "-not_for_dyld_shared_cache",
            "-Xlinker", "-install_name", "-Xlinker", install_name,
            "-Xlinker", "-exported_symbols_list", "-Xlinker", exports_file,
            "-enable-experimental-feature", "NonescapableTypes",
            "-enable-experimental-feature", "Lifetimes",
        ] + ["-Xlinker" if i % 2 == 0 else o
             for obj in extra_objs for i, o in enumerate([obj, obj])]
        # Simpler: just append object files directly
        final_cmd = [
            "swiftc", "-emit-library", "-o", final_dylib,
            gen_iface,
            "-enable-library-evolution", "-module-name", name,
            "-F", local_fw, "-sdk", SDK_ROOT,
            "-language-mode", "6",
            "-Xlinker", "-not_for_dyld_shared_cache",
            "-Xlinker", "-install_name", "-Xlinker", install_name,
            "-Xlinker", "-exported_symbols_list", "-Xlinker", exports_file,
            "-enable-experimental-feature", "NonescapableTypes",
            "-enable-experimental-feature", "Lifetimes",
        ] + extra_objs
        r = run(final_cmd)
        if r.returncode != 0 or not os.path.exists(final_dylib):
            result["error"] = f"final compile failed: {r.stderr[:300]}"
            return result

        # 5. Verify final symbol alignment
        dummy_stubs = os.path.join(work_dir, "dummy.s")
        final_missing, _ = run_compare(exports_file, final_dylib, dummy_stubs)
        result["final_missing"] = final_missing

        # 6. Declaration coverage: compare our generated interface vs Apple's swiftinterface
        with open(swiftinterface_path) as f:
            apple_text = f.read()
        with open(gen_iface) as f:
            gen_text = f.read()

        apple_types, apple_members = extract_declarations(apple_text)
        gen_types, gen_members = extract_declarations(gen_text)

        result["apple_types"] = len(apple_types)
        result["apple_members"] = len(apple_members)
        result["matched_types"] = len(apple_types & gen_types)
        result["matched_members"] = len(apple_members & gen_members)

        if apple_types:
            result["type_coverage"] = round(
                100.0 * result["matched_types"] / result["apple_types"], 1)
        if apple_members:
            result["member_coverage"] = round(
                100.0 * result["matched_members"] / result["apple_members"], 1)

    except Exception as e:
        result["error"] = str(e)

    return result

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Verify swift-interface-gen against public SDK frameworks")
    parser.add_argument("--frameworks", help="Comma-separated list of frameworks to test")
    parser.add_argument("--baseline", action="store_true", help="Save results as baseline")
    parser.add_argument("--compare-baseline", action="store_true", help="Compare against saved baseline")
    parser.add_argument("--jobs", type=int, default=4, help="Parallel workers")
    parser.add_argument("--all", action="store_true", help="Test all public Swift frameworks")
    args = parser.parse_args()

    # Build framework map
    all_fw = find_public_frameworks()
    print(f"Discovered {len(all_fw)} public Swift frameworks in SDK")

    if args.frameworks:
        selected = {n: all_fw[n] for n in args.frameworks.split(",") if n in all_fw}
        missing_names = [n for n in args.frameworks.split(",") if n not in all_fw]
        if missing_names:
            print(f"WARNING: not found: {missing_names}")
    elif args.all:
        selected = all_fw
    else:
        selected = {n: all_fw[n] for n in CURATED if n in all_fw}
        not_found = [n for n in CURATED if n not in all_fw]
        if not_found:
            print(f"NOTE: curated frameworks not in SDK: {not_found}")

    print(f"Testing {len(selected)} frameworks with {args.jobs} workers\n")
    print(f"{'Framework':<30} {'TBD syms':>9} {'1st-pass':>9} {'final':>7} {'type%':>7} {'member%':>8}  status")
    print("-" * 85)

    results = []
    work_root = tempfile.mkdtemp(prefix="verify_public_")

    def run_one(name_info):
        name, info = name_info
        work_dir = os.path.join(work_root, name)
        os.makedirs(work_dir, exist_ok=True)
        return test_framework(name, info["tbd"], info["swiftinterface"], work_dir)

    with ThreadPoolExecutor(max_workers=args.jobs) as ex:
        futures = {ex.submit(run_one, item): item[0] for item in selected.items()}
        for fut in as_completed(futures):
            r = fut.result()
            results.append(r)
            name = r["framework"]
            err = r["error"]
            fp = r["first_pass_stubs"]
            fin = r["final_missing"]
            tbd = r["tbd_symbols"]
            tc = r["type_coverage"]
            mc = r["member_coverage"]
            status = "ERROR" if err else ("PASS" if fin == 0 else "MISS")
            fp_str = str(fp) if fp >= 0 else "?"
            fin_str = str(fin) if fin >= 0 else "?"
            tc_str = f"{tc}%" if tc >= 0 else "?"
            mc_str = f"{mc}%" if mc >= 0 else "?"
            print(f"  {name:<28} {tbd:>9} {fp_str:>9} {fin_str:>7} {tc_str:>7} {mc_str:>8}  {status}")
            if err:
                print(f"    ↳ {err[:120]}")

    # Sort results by framework name
    results.sort(key=lambda r: r["framework"])

    print("\n" + "=" * 85)
    passed = sum(1 for r in results if r["final_missing"] == 0 and not r["error"])
    errors = sum(1 for r in results if r["error"])
    missing = sum(1 for r in results if r["final_missing"] != 0 and not r["error"])
    total_fp = sum(r["first_pass_stubs"] for r in results if r["first_pass_stubs"] >= 0)
    total_fin = sum(r["final_missing"] for r in results if r["final_missing"] >= 0)
    avg_tc = sum(r["type_coverage"] for r in results if r["type_coverage"] >= 0)
    n_tc = sum(1 for r in results if r["type_coverage"] >= 0)
    avg_mc = sum(r["member_coverage"] for r in results if r["member_coverage"] >= 0)
    n_mc = sum(1 for r in results if r["member_coverage"] >= 0)

    print(f"Results: {passed}/{len(results)} PASS, {missing} with missing symbols, {errors} errors")
    print(f"Total first-pass stubs: {total_fp}, Total final missing: {total_fin}")
    if n_tc:
        print(f"Avg type coverage:   {avg_tc/n_tc:.1f}%")
    if n_mc:
        print(f"Avg member coverage: {avg_mc/n_mc:.1f}%")

    # Write JSON results
    output_file = "public_fw_baseline.json" if args.baseline else "public_fw_results.json"
    with open(output_file, "w") as f:
        json.dump(results, f, indent=2)
    print(f"\nResults written to {output_file}")

    # Compare with baseline if requested
    if args.compare_baseline and os.path.exists("public_fw_baseline.json"):
        with open("public_fw_baseline.json") as f:
            baseline = {r["framework"]: r for r in json.load(f)}
        print("\n--- Regression vs baseline ---")
        regressions = []
        for r in results:
            b = baseline.get(r["framework"])
            if not b:
                continue
            fp_delta = (r["first_pass_stubs"] - b["first_pass_stubs"]) if r["first_pass_stubs"] >= 0 and b["first_pass_stubs"] >= 0 else None
            fin_delta = (r["final_missing"] - b["final_missing"]) if r["final_missing"] >= 0 and b["final_missing"] >= 0 else None
            if fp_delta and fp_delta > 0:
                regressions.append(f"  {r['framework']}: first-pass stubs +{fp_delta} ({b['first_pass_stubs']} → {r['first_pass_stubs']})")
            if fin_delta and fin_delta > 0:
                regressions.append(f"  {r['framework']}: final missing +{fin_delta} ({b['final_missing']} → {r['final_missing']})")
        if regressions:
            print("REGRESSIONS FOUND:")
            for reg in regressions:
                print(reg)
        else:
            print("No regressions vs baseline.")

    # Cleanup temp work dir
    shutil.rmtree(work_root, ignore_errors=True)

    return 0 if (missing == 0 and errors == 0) else 1

if __name__ == "__main__":
    sys.exit(main())
