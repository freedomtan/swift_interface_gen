#!/usr/bin/env python3
"""Categorize first-pass stub symbols (from a stubs_<Framework>.s assembly file, or several)
by demangled shape, to prioritize root-causing the generator's stub-elimination work.

Usage:
    python3 categorize_stubs.py <path/to/stubs_Framework.s> [more.s ...]
    python3 categorize_stubs.py --sample <bucket-name> <path/to/stubs_Framework.s>
"""
import re
import subprocess
import sys
import collections

BUCKET_PATTERNS = [
    ("default argument thunk", lambda s: "default argument" in s),
    ("protocol conformance descriptor", lambda s: s.startswith("protocol conformance descriptor for")),
    ("protocol witness table", lambda s: "protocol witness table" in s),
    ("property descriptor", lambda s: s.startswith("property descriptor for")),
    ("opaque type descriptor", lambda s: "opaque type descriptor" in s or "opaque return type" in s),
    ("property getter", lambda s: bool(re.search(r"\.getter$", s))),
    ("property setter", lambda s: bool(re.search(r"\.setter$", s))),
    ("property modify accessor", lambda s: bool(re.search(r"\.modify$", s))),
    ("protocol requirements base descriptor", lambda s: "protocol requirements base descriptor" in s),
    ("protocol descriptor", lambda s: "protocol descriptor for" in s),
    ("nominal type descriptor", lambda s: "nominal type descriptor" in s),
    ("type metadata", lambda s: s.startswith("type metadata for") or "metadata accessor" in s),
    ("value witness table", lambda s: "value witness table" in s),
    ("reflection metadata", lambda s: "reflection metadata" in s),
    ("async function pointer", lambda s: "async function pointer" in s),
    ("partial apply forwarder", lambda s: "partial apply" in s),
    ("objc class/metaclass", lambda s: s.startswith("_OBJC_CLASS_$_") or s.startswith("_OBJC_METACLASS_$_")),
]


def classify(demangled):
    for name, pred in BUCKET_PATTERNS:
        if pred(demangled):
            return name
    return "other/function"


def extract_symbols(path):
    syms = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line.startswith(".globl"):
                syms.append(line.split()[1])
    return syms


def demangle_all(syms):
    if not syms:
        return []
    proc = subprocess.run(
        ["xcrun", "swift-demangle", "-simplified"],
        input="\n".join(syms), capture_output=True, text=True
    )
    return proc.stdout.splitlines()


def main():
    args = sys.argv[1:]
    sample_bucket = None
    if args and args[0] == "--sample":
        sample_bucket = args[1]
        args = args[2:]
    if not args:
        print(__doc__)
        sys.exit(1)

    all_syms = []
    per_file = {}
    for path in args:
        syms = extract_symbols(path)
        per_file[path] = syms
        all_syms.extend(syms)

    demangled = demangle_all(all_syms)
    buckets = collections.Counter()
    bucket_examples = collections.defaultdict(list)
    for mangled, d in zip(all_syms, demangled):
        b = classify(d)
        buckets[b] += 1
        bucket_examples[b].append((mangled, d))

    if sample_bucket:
        for mangled, d in bucket_examples.get(sample_bucket, [])[:30]:
            print(f"{mangled}\n  ---> {d}\n")
        print(f"(showing up to 30 of {buckets.get(sample_bucket, 0)} in bucket '{sample_bucket}')")
        return

    print(f"Total symbols: {len(all_syms)}")
    for path, syms in per_file.items():
        print(f"  {path}: {len(syms)}")
    print()
    for name, count in buckets.most_common():
        print(f"{count:6d}  {name}")


if __name__ == "__main__":
    main()
