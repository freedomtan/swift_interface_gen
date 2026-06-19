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
public enum AppleIntelligenceErrorCategory: Int, Codable, Hashable, Sendable {
    case unknown
}
SWIFTEOF
    swiftc -emit-library -o "LocalFrameworks/AppleIntelligenceReporting.framework/AppleIntelligenceReporting" \
        /tmp/_air_stub.swift -enable-library-evolution -module-name AppleIntelligenceReporting -sdk "$SDK_ROOT" -language-mode 5 \
        -emit-module-interface-path "LocalFrameworks/AppleIntelligenceReporting.framework/Modules/AppleIntelligenceReporting.swiftmodule/arm64-apple-macos.swiftinterface" \
        -emit-module-path "LocalFrameworks/AppleIntelligenceReporting.framework/Modules/AppleIntelligenceReporting.swiftmodule/arm64-apple-macos.swiftmodule" 2>/dev/null || true
fi

# UnifiedAssetFramework stub
if [ ! -d "LocalFrameworks/UnifiedAssetFramework.framework/Modules" ]; then
    mkdir -p "LocalFrameworks/UnifiedAssetFramework.framework/Modules/UnifiedAssetFramework.swiftmodule"
    cat > /tmp/_uaf_stub.swift << 'SWIFTEOF'
import Foundation
public class UAFAssetSetConsistencyToken: NSObject {}
public class UAFAsset: NSObject {}
public class UAFAssetSet: NSObject {}
public enum UAFSubscriptionDownloadStatus: Int, Codable, Hashable, Sendable {
    case unknown
}
SWIFTEOF
    swiftc -emit-library -o "LocalFrameworks/UnifiedAssetFramework.framework/UnifiedAssetFramework" \
        /tmp/_uaf_stub.swift -enable-library-evolution -module-name UnifiedAssetFramework -sdk "$SDK_ROOT" -language-mode 5 \
        -emit-module-interface-path "LocalFrameworks/UnifiedAssetFramework.framework/Modules/UnifiedAssetFramework.swiftmodule/arm64-apple-macos.swiftinterface" \
        -emit-module-path "LocalFrameworks/UnifiedAssetFramework.framework/Modules/UnifiedAssetFramework.swiftmodule/arm64-apple-macos.swiftmodule" 2>/dev/null || true
fi

echo "--- Generating Interface for $FRAMEWORK ---"
./swift-interface-gen "$TBD_PATH" > "${FRAMEWORK}Interface.swift"

echo "--- Preparing Local Framework ---"
MODULE_DIR="LocalFrameworks/${FRAMEWORK}.framework/Modules/${FRAMEWORK}.swiftmodule"
mkdir -p "$MODULE_DIR"

echo "--- Emitting Swift Module Interface ---"
# Strip stubs to prevent duplicate/conflicting symbols during module compilation
sed -n '/\/\/ --- Automatically Generated Self-Alignment Stubs ---/q;p' "${FRAMEWORK}Interface.swift" > "/tmp/${FRAMEWORK}Interface_module.swift"

swiftc -emit-module -module-name "$FRAMEWORK" "/tmp/${FRAMEWORK}Interface_module.swift" \
    -enable-experimental-feature NonescapableTypes -enable-experimental-feature Lifetimes \
    -enable-library-evolution -language-mode 6 -F LocalFrameworks \
    -sdk "$SDK_ROOT" \
    -emit-module-interface-path "$MODULE_DIR/arm64-apple-macos.swiftinterface" \
    -o "$MODULE_DIR/arm64-apple-macos.swiftmodule"

rm -f "/tmp/${FRAMEWORK}Interface_module.swift"

echo "--- Compiling Mock Dynamic Library ---"
# Strip default argument assignments to prevent compiler-generated local default arg getters that conflict with the stubs
sed 's/ = dummyDefaultValue()//g' "${FRAMEWORK}Interface.swift" > "/tmp/${FRAMEWORK}Interface_dylib.swift"

LINKER_FLAGS=""
if [ -f "${FRAMEWORK}_exports.txt" ]; then
    LINKER_FLAGS="$LINKER_FLAGS -Xlinker -exported_symbols_list -Xlinker ${FRAMEWORK}_exports.txt"
fi

swiftc -emit-library -o "LocalFrameworks/${FRAMEWORK}.framework/${FRAMEWORK}" \
    -enable-experimental-feature NonescapableTypes -enable-experimental-feature Lifetimes \
    "/tmp/${FRAMEWORK}Interface_dylib.swift" \
    -enable-library-evolution -module-name "$FRAMEWORK" -F LocalFrameworks \
    -sdk "$SDK_ROOT" -language-mode 6 $LINKER_FLAGS

rm -f "/tmp/${FRAMEWORK}Interface_dylib.swift"

echo "--- Comparing Symbols (Verification) ---"
rm -f dummy_stubs.s stubs.s stubs.o
./swift-interface-gen --compare "${FRAMEWORK}_exports.txt" "LocalFrameworks/${FRAMEWORK}.framework/${FRAMEWORK}" dummy_stubs.s

# Clean up temporary files
rm -f dummy_stubs.s "${FRAMEWORK}_exports.txt"

echo "--- Compiling Test Program ---"
swiftc -F LocalFrameworks "$TEST_FILE" \
    -enable-experimental-feature NonescapableTypes -enable-experimental-feature Lifetimes \
    -sdk "$SDK_ROOT" -language-mode 6 \
    -o "${FRAMEWORK}_test_run"

echo "--- Codesigning ---"
codesign --force -s - "${FRAMEWORK}_test_run"

echo "--- Running Test ---"
DYLD_FRAMEWORK_PATH=LocalFrameworks ./"${FRAMEWORK}_test_run"
