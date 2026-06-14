# Swift Interface Generator

`swift-interface-gen` is a command-line tool designed to generate clean, compilable Swift interfaces (`.swiftinterface` and `.swift`) directly from macOS/iOS Text-Based Stub (`.tbd`) files. 

This tool is primarily used for reverse-engineering and reconstructing the public Swift APIs of private Apple frameworks, allowing developers to link against them and explore their capabilities in standalone test programs.

## Features

- **Automated Demangling:** Leverages the native Swift demangler (`_stdlib_demangle`) to accurately reconstruct types, methods, and properties from mangled symbols.
- **Zero-Config Dynamic Inference:** Automatically infers complex multi-parameter generics, dotted protocol namespaces, and concrete types without relying on hardcoded lists.
- **Local Framework Bundling:** Generates a complete, self-contained `.framework` structure (including `.swiftmodule` and `.swiftinterface`) that can be seamlessly passed to the Swift compiler using standard `-F` flags.
- **Mock Executability:** Generates safe mock implementations (e.g., empty initializers `{}`, safe default return values like `[]` or `nil`, and `fatalError()` for complex logic). This allows client code to successfully instantiate objects and verify type layouts at runtime without crashing immediately.
- **Smart Dependency Resolution:** Automatically detects and resolves cross-module dependencies (e.g., pulling in `CoreAICommon` when parsing `CoreAICompiler`) by scanning system `PrivateFrameworks` and `SubFrameworks`.

## Quick Start (Automation Script)

The easiest way to use the tool is via the included `automate.sh` script, which handles the entire pipeline: building the generator, parsing the `.tbd` file, bundling the local framework, and compiling your test program.

1. **Create a Test File** (e.g., `test_ModelCatalog.swift`):
   ```swift
   import Foundation
   import ModelCatalog

   print("Starting test...")
   let client = CatalogClient()
   print("Successfully instantiated CatalogClient!")
   ```

2. **Run the Automation Script**:
   Pass the name of the system framework you want to reconstruct and your test file.
   ```bash
   ./automate.sh ModelCatalog test_ModelCatalog.swift
   ```

This script will output the reconstructed framework into the `LocalFrameworks/` directory and execute your test binary.

## Manual Usage

If you prefer to run the steps manually:

### 1. Build the Generator
```bash
cd SwiftInterfaceGen/Sources/SwiftInterfaceGen
swiftc -parse-as-library main.swift Parser.swift Model.swift Config.swift -o ../../../swift-interface-gen
cd ../../../
```

### 2. Generate the Interface Source
*Note: We pipe through python to safely handle complex regex escaping across platforms.*
```bash
./swift-interface-gen /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/PrivateFrameworks/ModelCatalog.framework/ModelCatalog.tbd | python3 -c "import sys; print(sys.stdin.read().replace('\\\\n', '\n').replace('(Optional,', '(Optional<Any>,').replace('(Optional ,', '(Optional<Any>,'))" > ModelCatalogInterface.swift
```

### 3. Create the Local Framework Structure
```bash
mkdir -p LocalFrameworks/ModelCatalog.framework/Modules/ModelCatalog.swiftmodule

# Emit Module Interface
swiftc -emit-module -module-name ModelCatalog ModelCatalogInterface.swift \
    -enable-library-evolution -language-mode 5 -F LocalFrameworks \
    -sdk /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk \
    -emit-module-interface-path LocalFrameworks/ModelCatalog.framework/Modules/ModelCatalog.swiftmodule/arm64-apple-macos.swiftinterface \
    -o LocalFrameworks/ModelCatalog.framework/Modules/ModelCatalog.swiftmodule/arm64-apple-macos.swiftmodule

# Compile Mock Dynamic Library
swiftc -emit-library -o LocalFrameworks/ModelCatalog.framework/ModelCatalog \
    ModelCatalogInterface.swift -enable-library-evolution -module-name ModelCatalog \
    -F LocalFrameworks -sdk /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk
```

### 4. Compile Your Client Code
```bash
swiftc -F LocalFrameworks test_ModelCatalog.swift \
    -sdk /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk \
    -o test_run

# Run against the local framework
DYLD_FRAMEWORK_PATH=LocalFrameworks ./test_run
```

## 100% Dynamic Inference (No Configuration Required)

This tool has been fully refactored to achieve **100% dynamic inference**. There is no longer a need for `config.json` or manual override files. 

All generic parameter counts, namespaces, type definitions, protocol conformances, and concrete/protocol type classifications are inferred automatically at runtime by scanning and parsing the demangled binary symbols and referencing the SDK's metadata headers.

For backward compatibility, the `--config` parameter is still accepted but operates as a no-op.

## Security, Entitlements, and AMFI

When writing integration tests that actually invoke methods requiring XPC services or secure enclaves (rather than just inspecting types), you must link against the *real* system framework and sign your binary with private entitlements.

```bash
codesign --force --options runtime --entitlements ModelCatalog.entitlements -s - test_integration_run
```

**⚠️ Important:** Ad-hoc codesigning with private Apple entitlements is generally only effective on devices where **AMFI (Apple Mobile File Integrity)** has been disabled (e.g., via the `amfi_get_out_of_my_way=1` boot argument). On standard macOS configurations, the kernel will immediately kill (`Killed: 9`) binaries attempting to impersonate system entitlements.
