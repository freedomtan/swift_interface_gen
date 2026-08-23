#!/usr/bin/env python3
import re
import subprocess
import sys

TESTS = [
    ("CoreAICommon", "test_CoreAICommon.swift"),
    ("CoreAICompiler", "test_CoreAICompiler.swift"),
    ("CoreAIDelegates", "test_CoreAIDelegates.swift"),
    ("ODIE", "test_ODIE.swift"),
    ("AppleIntelligenceReporting", "test_AppleIntelligenceReporting.swift"),
    ("UnifiedAssetFramework", "test_UnifiedAssetFramework.swift"),
    ("ModelCatalog", "test_ModelCatalog.swift"),
    ("ModelCatalogRuntime", "test_ModelCatalogRuntime.swift"),
    ("TokenGenerationCore", "test_TokenGenerationCore.swift"),
]


def parse_first_pass_stubs(output, target):
    # orchestrate.py's Phase C ("Comparing and Generating Assembly Stubs") emits this line
    # after the first-pass compile (before assembly stubs are linked in) -- match specifically
    # on stubs_{target}.s so a dependency's own "Generated N stubs in stubs_{dep}.s" line
    # (recursively built as part of this same run) isn't mistaken for the target's own count.
    m = re.search(rf"Generated (\d+) stubs in stubs_{re.escape(target)}\.s", output)
    return int(m.group(1)) if m else -1


def main():
    print("=" * 60)
    print("RUNNING REGRESSION TESTS FOR ALL TARGET FRAMEWORKS")
    print("=" * 60)

    success = True
    failed_targets = []
    results = []  # (target, status, first_pass_stubs)

    for target, test_file in TESTS:
        print(f"\n[+] Testing target: {target} using {test_file}...")
        cmd = ["./orchestrate.py", target, test_file]
        try:
            res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, check=True)
            fp = parse_first_pass_stubs(res.stdout, target)
            fp_str = str(fp) if fp >= 0 else "?"
            print(f"    SUCCESS: {target} compiled and verified passing! (first-pass stubs: {fp_str})")
            results.append((target, "PASS", fp))
        except subprocess.CalledProcessError as e:
            fp = parse_first_pass_stubs(e.output, target)
            print(f"    FAILURE: {target} failed to compile/verify!")
            print("-" * 40)
            # Show the last 20 lines of output for context
            lines = e.output.splitlines()
            last_lines = lines[-30:] if len(lines) > 30 else lines
            for line in last_lines:
                print("    " + line)
            print("-" * 40)
            success = False
            failed_targets.append(target)
            results.append((target, "FAIL", fp))

    print("\n" + "=" * 60)
    print("FIRST-PASS STUB SUMMARY")
    print("=" * 60)
    print(f"{'Framework':<30} {'1st-pass':>9}  status")
    total_fp = 0
    for target, status, fp in results:
        fp_str = str(fp) if fp >= 0 else "?"
        if fp >= 0:
            total_fp += fp
        print(f"  {target:<28} {fp_str:>9}  {status}")
    print(f"\nTotal first-pass stubs: {total_fp}")

    print("\n" + "=" * 60)
    if success:
        print("ALL REGRESSION TESTS PASSED SUCCESSFULLY!")
        sys.exit(0)
    else:
        print(f"REGRESSION TESTS FAILED FOR TARGETS: {', '.join(failed_targets)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
