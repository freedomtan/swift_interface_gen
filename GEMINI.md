# Swift Interface Generator

A tool to generate clean, compilable Swift interfaces from TBD (text-based stub) files. This is primarily used to reconstruct the public API of private frameworks for development and testing purposes.

## Goals
- **Accuracy:** Correctly demangle and reconstruct Swift types, methods, and properties.
- **Compilability:** Produce code that can be compiled as a standalone module to satisfy link-time requirements.
- **Readability:** Generate clean Swift code by stripping redundant module prefixes and simplifying complex signatures.

## Implementation Progress (2026)
- [x] **Demangling Engine:** Uses `_stdlib_demangle` via `@_silgen_name`.
- [x] **Type Simplification:** Automatically removes redundant prefixes and strips demangler-injected numeric suffixes (e.g., `Bool12345`).
- [x] **Local Framework Support:** Successfully generates `.framework` structures containing `.swiftinterface` and dynamic libraries for seamless client integration.
- [x] **Mock Strategy:** Produces empty bodies (`{}`) for all initializers, enabling object instantiation in client code, while preserving `fatalError()` for functional methods.
- [x] **Generic Fallbacks:** Robust handling of bare `Optional`, `Criteria`, `Array`, and `Dictionary` types without generic parameters in demangled output.
- [x] **Circular Alias Protection:** Prevents self-referencing typealiases (e.g., `typealias NSCoder = NSCoder`) by intelligently managing module prefixes.
- [x] **Enum & Protocol Support:** Full reconstruction of enum cases and protocol conformances from TBD symbols.

## Technical Insights & Lessons Learned

### 1. The Local Framework Strategy
Initially, linking against generated interfaces required passing raw `.o` files to the compiler. We have transitioned to a standard framework structure:
- **`Modules/ModuleName.swiftmodule/arm64-apple-macos.swiftinterface`**: Allows the compiler to see the API without binary dependencies.
- **`ModuleName.framework/ModuleName`**: A dynamic library containing the mock implementations, ensuring symbols are available at link-time and runtime.
- **`DYLD_FRAMEWORK_PATH`**: Using this environment variable allows test programs to load the local mock framework instead of (or in conjunction with) system frameworks.

### 2. Mocking for Testability
To allow client code to actually *run* (even if just to verify instantiation), the generator now differentiates between members:
- **Initializers:** Generated with empty bodies `{}`.
- **Methods/Properties:** Generated with `fatalError()`.
This allows patterns like `let client = CatalogClient()` to succeed while still providing immediate feedback if a mock method is called.

### 3. Post-Processing & Normalization
The Swift demangler often produces "half-baked" types. Our `postProcess` pipeline now surgically fixes:
- **Generic Missingness:** Regex-based insertion of `<Any>` for `Optional`, `Criteria`, and other common generic types that appear without parameters.
- **Module Prefixes:** Stripping `ModelCatalog.` but preserving `Foundation.` where necessary to avoid circularity.
- **Unnamed Parameters:** Normalizing `(_: Type)` to `(arg1: Type)`.

## Technical Conventions
- **Tool:** Swift executable target located in `SwiftInterfaceGen/`.
- **Core Logic:** 
    - `Parser.swift`: Handles symbol parsing and type tree construction.
    - `Model.swift`: Defines the IR (Intermediate Representation) and code generation logic.
- **Output:** Defaults to generating `GeneratedInterface.swift`.

## Compilation and Execution

### 1. Build the Generator Tool
```bash
cd SwiftInterfaceGen/Sources/SwiftInterfaceGen
swiftc -parse-as-library main.swift Parser.swift Model.swift -o ../../swift-interface-gen
cd ../../
```

### 2. Generate and Bundle the Framework
```bash
# Generate the interface source
./swift-interface-gen /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/PrivateFrameworks/ModelCatalog.framework/ModelCatalog.tbd | python3 -c "import sys; print(sys.stdin.read().replace('\\\\n', '\n'))" > GeneratedInterface.swift

# Prepare Framework structure
mkdir -p LocalFrameworks/ModelCatalog.framework/Modules/ModelCatalog.swiftmodule

# Generate .swiftinterface and .swiftmodule
swiftc -emit-module -module-name ModelCatalog GeneratedInterface.swift \
    -enable-library-evolution -language-mode 5 \
    -sdk /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk \
    -emit-module-interface-path LocalFrameworks/ModelCatalog.framework/Modules/ModelCatalog.swiftmodule/arm64-apple-macos.swiftinterface \
    -o LocalFrameworks/ModelCatalog.framework/Modules/ModelCatalog.swiftmodule/arm64-apple-macos.swiftmodule

# Generate the Dynamic Library (Mock Implementation)
swiftc -emit-library -o LocalFrameworks/ModelCatalog.framework/ModelCatalog \
    GeneratedInterface.swift -enable-library-evolution -module-name ModelCatalog \
    -sdk /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk
```

### 3. Compile and Run a Client
```bash
# Compile against the local framework
swiftc -F LocalFrameworks test_types.swift \
    -sdk /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk \
    -o test_types_run

# Codesign with entitlements (required for integration tests)
codesign --force --options runtime --entitlements ModelCatalog.entitlements -s - test_types_run

# Run with local framework path
DYLD_FRAMEWORK_PATH=LocalFrameworks ./test_types_run
```

**Note on Codesigning & AMFI:** Ad-hoc codesigning (`-s -`) with private entitlements is required for integration tests that interact with system services. This is generally only effective for execution on devices where **AMFI (Apple Mobile File Integrity)** has been disabled. Basic metadata tests (like `test_types_run`) may not require entitlements to run.

## Known Limitations
- **Private Framework Dependencies:** Some frameworks depend on other private frameworks. The tool currently supports smart discovery of these dependencies if they are in the same search path.
- **Complex Variadic Generics:** Rare Swift symbols involving variadic generics may still produce malformed signatures.
