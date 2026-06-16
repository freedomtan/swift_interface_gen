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

echo "--- Compiling Mock Dynamic Library ---"
swiftc -emit-library -o "LocalFrameworks/${FRAMEWORK}.framework/${FRAMEWORK}" \
    "${FRAMEWORK}Interface.swift" \
    -enable-library-evolution -module-name "$FRAMEWORK" -F LocalFrameworks \
    -sdk "$SDK_ROOT" -language-mode 5

# Generate aliases using comparison script
rm -f aliases.txt
python3 /Users/freedom/.gemini/antigravity-cli/brain/0fd91ff0-a8f2-4abf-90e3-666140999f13/scratch/compare_symbols.py "$TBD_PATH" "LocalFrameworks/${FRAMEWORK}.framework/${FRAMEWORK}" aliases.txt

if [ -f aliases.txt ] && [ -s aliases.txt ]; then
    echo "--- Re-compiling Mock Dynamic Library with Symbol Aliases ---"
    ALIAS_FLAGS=$(cat aliases.txt)
    swiftc -emit-library -o "LocalFrameworks/${FRAMEWORK}.framework/${FRAMEWORK}" \
        "${FRAMEWORK}Interface.swift" \
        -enable-library-evolution -module-name "$FRAMEWORK" -F LocalFrameworks \
        -sdk "$SDK_ROOT" -language-mode 5 $ALIAS_FLAGS
fi

echo "--- Compiling Test Program ---"
swiftc -F LocalFrameworks "$TEST_FILE" \
    -sdk "$SDK_ROOT" -language-mode 5 \
    -o "${FRAMEWORK}_test_run"

echo "--- Codesigning ---"
codesign --force -s - "${FRAMEWORK}_test_run"

echo "--- Running Test ---"
DYLD_FRAMEWORK_PATH=LocalFrameworks ./"${FRAMEWORK}_test_run"
