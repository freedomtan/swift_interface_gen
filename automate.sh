#!/bin/bash

# automate.sh <FrameworkName> <TestFile.swift>
# Example: ./automate.sh GenerativeModels test_types.swift

set -e

FRAMEWORK=$1
TEST_FILE=$2
if [ -z "$SDK_ROOT" ]; then
    SDK_ROOT=$(xcrun --show-sdk-path 2>/dev/null || echo "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk")
fi
PRIVATE_FRAMEWORKS="/System/Library/PrivateFrameworks"
SUB_FRAMEWORKS="/System/Library/SubFrameworks"

if [ -z "$FRAMEWORK" ] || [ -z "$TEST_FILE" ]; then
    echo "Usage: ./automate.sh <FrameworkName> <TestFile.swift>"
    exit 1
fi

TBD_PATH="${SDK_ROOT}${PRIVATE_FRAMEWORKS}/${FRAMEWORK}.framework/${FRAMEWORK}.tbd"

if [ ! -f "$TBD_PATH" ]; then
    TBD_PATH="${SDK_ROOT}${PRIVATE_FRAMEWORKS}/${FRAMEWORK}.framework/Versions/A/${FRAMEWORK}.tbd"
fi
if [ ! -f "$TBD_PATH" ]; then
    TBD_PATH="${SDK_ROOT}${PRIVATE_FRAMEWORKS}/${FRAMEWORK}.framework/Versions/Current/${FRAMEWORK}.tbd"
fi
if [ ! -f "$TBD_PATH" ]; then
    TBD_PATH="${SDK_ROOT}${SUB_FRAMEWORKS}/${FRAMEWORK}.framework/${FRAMEWORK}.tbd"
fi
if [ ! -f "$TBD_PATH" ]; then
    TBD_PATH="${SDK_ROOT}${SUB_FRAMEWORKS}/${FRAMEWORK}.framework/Versions/A/${FRAMEWORK}.tbd"
fi
if [ ! -f "$TBD_PATH" ]; then
    TBD_PATH="${SDK_ROOT}${SUB_FRAMEWORKS}/${FRAMEWORK}.framework/Versions/Current/${FRAMEWORK}.tbd"
fi

if [ ! -f "$TBD_PATH" ]; then
    echo "Error: Could not find TBD for $FRAMEWORK at $TBD_PATH"
    exit 1
fi

echo "--- Building Generator ---"
cd SwiftInterfaceGen/Sources/SwiftInterfaceGen
swiftc -O -parse-as-library main.swift Parser.swift Model.swift Config.swift String+RegexFree.swift -o ../../../swift-interface-gen
cd ../../../

echo "--- Building Dependency Stub Frameworks ---"
# Create minimal stub frameworks for private dependencies that lack Swift modules.
# These are needed so that the generated interface can import real module-qualified types.

# AppleIntelligenceReporting stub
if [ ! -d "LocalFrameworks/AppleIntelligenceReporting.framework/Modules" ]; then
    mkdir -p "LocalFrameworks/AppleIntelligenceReporting.framework/Modules/AppleIntelligenceReporting.swiftmodule"
    cat > /tmp/_air_stub.swift << 'SWIFTEOF'
import Foundation
public protocol AppleIntelligenceError: Error {
    var underlyingErrors: [any AppleIntelligenceError] { get }
    var category: AppleIntelligenceErrorCategory { get }
}
public struct AppleIntelligenceErrorCategory: Codable, Hashable, Sendable { public init() {} }
SWIFTEOF
    swiftc -emit-library -o "LocalFrameworks/AppleIntelligenceReporting.framework/AppleIntelligenceReporting" \
        /tmp/_air_stub.swift -enable-library-evolution -module-name AppleIntelligenceReporting -sdk "$SDK_ROOT" -language-mode 5 \
        -emit-module-interface-path "LocalFrameworks/AppleIntelligenceReporting.framework/Modules/AppleIntelligenceReporting.swiftmodule/arm64-apple-macos.swiftinterface" \
        -emit-module-path "LocalFrameworks/AppleIntelligenceReporting.framework/Modules/AppleIntelligenceReporting.swiftmodule/arm64-apple-macos.swiftmodule" 2>/dev/null || true
fi

# FeatureFlags stub
if [ ! -d "LocalFrameworks/FeatureFlags.framework/Modules" ]; then
    mkdir -p "LocalFrameworks/FeatureFlags.framework/Modules/FeatureFlags.swiftmodule"
    cat > /tmp/_ff_stub.swift << 'SWIFTEOF'
public protocol FeatureFlagsKey {
    var domain: StaticString { get }
    var feature: StaticString { get }
}
SWIFTEOF
    swiftc -emit-library -o "LocalFrameworks/FeatureFlags.framework/FeatureFlags" \
        /tmp/_ff_stub.swift -enable-library-evolution -module-name FeatureFlags -sdk "$SDK_ROOT" -language-mode 5 \
        -emit-module-interface-path "LocalFrameworks/FeatureFlags.framework/Modules/FeatureFlags.swiftmodule/arm64-apple-macos.swiftinterface" \
        -emit-module-path "LocalFrameworks/FeatureFlags.framework/Modules/FeatureFlags.swiftmodule/arm64-apple-macos.swiftmodule" 2>/dev/null || true
fi

echo "--- Generating Interface for $FRAMEWORK ---"
./swift-interface-gen "$TBD_PATH" > "${FRAMEWORK}Interface.swift"

echo "--- Preparing Local Framework ---"
MODULE_DIR="LocalFrameworks/${FRAMEWORK}.framework/Modules/${FRAMEWORK}.swiftmodule"
mkdir -p "$MODULE_DIR"

echo "--- Emitting Swift Module Interface ---"
swiftc -emit-module -module-name "$FRAMEWORK" "${FRAMEWORK}Interface.swift" \
    -enable-library-evolution -language-mode 5 -F LocalFrameworks \
    -sdk "$SDK_ROOT" \
    -emit-module-interface-path "$MODULE_DIR/arm64-apple-macos.swiftinterface" \
    -o "$MODULE_DIR/arm64-apple-macos.swiftmodule" || echo "Warning: Module emission had issues, continuing to mock library generation..."

echo "--- Compiling Mock Dynamic Library (First Pass) ---"
swiftc -emit-library -o "LocalFrameworks/${FRAMEWORK}.framework/${FRAMEWORK}" \
    "${FRAMEWORK}Interface.swift" \
    -enable-library-evolution -module-name "$FRAMEWORK" -F LocalFrameworks \
    -sdk "$SDK_ROOT" -language-mode 5

# Generate stubs using the compare tool
rm -f stubs.s stubs.o dummy_stubs.s
echo "--- Comparing Symbols (First Pass / Pre-Alignment) ---"
./swift-interface-gen --compare "${FRAMEWORK}_exports.txt" "LocalFrameworks/${FRAMEWORK}.framework/${FRAMEWORK}" stubs.s

if [ -f stubs.s ] && [ -s stubs.s ]; then
    echo "--- Compiling Assembly Stubs ---"
    clang -c stubs.s -o stubs.o
fi

echo "--- Re-compiling Mock Dynamic Library with Exact Symbol Alignment ---"
LINKER_FLAGS=""
if [ -f "${FRAMEWORK}_exports.txt" ]; then
    LINKER_FLAGS="$LINKER_FLAGS -Xlinker -exported_symbols_list -Xlinker ${FRAMEWORK}_exports.txt"
fi

EXTRA_OBJECTS=""
if [ -f stubs.o ]; then
    EXTRA_OBJECTS="stubs.o"
fi

swiftc -emit-library -o "LocalFrameworks/${FRAMEWORK}.framework/${FRAMEWORK}" \
    "${FRAMEWORK}Interface.swift" $EXTRA_OBJECTS \
    -enable-library-evolution -module-name "$FRAMEWORK" -F LocalFrameworks \
    -sdk "$SDK_ROOT" -language-mode 5 $LINKER_FLAGS

echo "--- Comparing Symbols (Final Pass / Post-Alignment) ---"
./swift-interface-gen --compare "${FRAMEWORK}_exports.txt" "LocalFrameworks/${FRAMEWORK}.framework/${FRAMEWORK}" dummy_stubs.s

# Clean up temporary files
rm -f stubs.s stubs.o dummy_stubs.s "${FRAMEWORK}_exports.txt"

echo "--- Compiling Test Program ---"
swiftc -F LocalFrameworks "$TEST_FILE" \
    -sdk "$SDK_ROOT" -language-mode 5 \
    -o "${FRAMEWORK}_test_run"

echo "--- Codesigning ---"
codesign --force -s - "${FRAMEWORK}_test_run"

echo "--- Running Test ---"
DYLD_FRAMEWORK_PATH=LocalFrameworks ./"${FRAMEWORK}_test_run"
