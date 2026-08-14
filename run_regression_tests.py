#!/usr/bin/env python3
import subprocess
import sys

TESTS = [
    ("CoreAICommon", "test_CoreAICommon.swift"),
    ("CoreAICompiler", "test_CoreAICompiler.swift"),
    ("ODIE", "test_ODIE.swift"),
    ("CoreAIDelegates", "test_CoreAIDelegates.swift"),
    ("AppleIntelligenceReporting", "test_AppleIntelligenceReporting.swift"),
    ("UnifiedAssetFramework", "test_UnifiedAssetFramework.swift"),
    ("ModelCatalog", "test_ModelCatalog.swift"),
    ("ModelCatalogRuntime", "test_ModelCatalogRuntime.swift"),
    ("TokenGenerationCore", "test_TokenGenerationCore.swift"),
]

def main():
    print("=" * 60)
    print("RUNNING REGRESSION TESTS FOR ALL TARGET FRAMEWORKS")
    print("=" * 60)
    
    success = True
    failed_targets = []
    
    for target, test_file in TESTS:
        print(f"\n[+] Testing target: {target} using {test_file}...")
        cmd = ["./orchestrate.py", target, test_file]
        try:
            res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, check=True)
            print(f"    SUCCESS: {target} compiled and verified passing!")
        except subprocess.CalledProcessError as e:
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
            
    print("\n" + "=" * 60)
    if success:
        print("ALL REGRESSION TESTS PASSED SUCCESSFULLY!")
        sys.exit(0)
    else:
        print(f"REGRESSION TESTS FAILED FOR TARGETS: {', '.join(failed_targets)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
