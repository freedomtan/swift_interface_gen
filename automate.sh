#!/bin/bash

# automate.sh <FrameworkName> <TestFile.swift>
# Example: ./automate.sh GenerativeModels test_types.swift

set -e

FRAMEWORK=$1
TEST_FILE=$2
SDK_ROOT="/Library/Developer/CommandLineTools/SDKs/MacOSX27.0.sdk"
PRIVATE_FRAMEWORKS="/System/Library/PrivateFrameworks"

if [ -z "$FRAMEWORK" ] || [ -z "$TEST_FILE" ]; then
    echo "Usage: ./automate.sh <FrameworkName> <TestFile.swift>"
    exit 1
fi

TBD_PATH="${SDK_ROOT}${PRIVATE_FRAMEWORKS}/${FRAMEWORK}.framework/${FRAMEWORK}.tbd"

if [ ! -f "$TBD_PATH" ]; then
    # Try alternate path
    TBD_PATH="${SDK_ROOT}${PRIVATE_FRAMEWORKS}/${FRAMEWORK}.framework/Versions/A/${FRAMEWORK}.tbd"
fi

if [ ! -f "$TBD_PATH" ]; then
    echo "Error: Could not find TBD for $FRAMEWORK at $TBD_PATH"
    exit 1
fi

echo "--- Building Generator ---"
swiftc SwiftInterfaceGen/Sources/SwiftInterfaceGen/*.swift -o ./swift-interface-gen -parse-as-library

echo "--- Generating Interface for $FRAMEWORK ---"
# We use a python script to handle the complex regex replacements that are hard in pure bash/sed
./swift-interface-gen "$TBD_PATH" | python3 -c "
import sys, re

content = sys.stdin.read().replace('\\\\n', '\n')

# 1. Fix malformed Optional types produced by demangler closures
content = re.sub(r'\\bOptional\\b(?![<])', 'Optional<Any>', content)

# 2. Fix promptFragments malformed set block
content = re.sub(r': Array<Any } set \{ fatalError\(\) \} \}', ': Array<Any> { get { fatalError() } set { fatalError() } }', content)
content = re.sub(r'Array<Any \}', 'Array<Any>', content)

# 3. Fix generic constraints in type aliases/closures
content = re.sub(r'== String>', '>', content)
content = re.sub(r'== A>', '>', content)

# 4. Remove doubled existential any
content = re.sub(r'any any ', 'any ', content)

# 5. Fix malformed extension artifacts
content = re.sub(r'\(extension in [^)]+\):', '', content)
content = re.sub(r'\\(\\bextension\\b[^)]+\\)', 'Any', content)

# 6. Final brace safety
content = re.sub(r'\\bAny \}', 'Any', content)

print(content)
" > "${FRAMEWORK}Interface.swift"

echo "--- Compiling Module $FRAMEWORK ---"
swiftc -emit-module -module-name "$FRAMEWORK" "${FRAMEWORK}Interface.swift" \
    -enable-library-evolution \
    -o "${FRAMEWORK}.swiftmodule" \
    -sdk "$SDK_ROOT" || echo "Warning: Module emission had issues, attempting object compilation anyway..."

echo "--- Compiling Object File ---"
swiftc -c -module-name "$FRAMEWORK" "${FRAMEWORK}Interface.swift" \
    -enable-library-evolution \
    -parse-as-library \
    -o "${FRAMEWORK}.o" \
    -sdk "$SDK_ROOT"

echo "--- Compiling Test Program ---"
swiftc -I . "$TEST_FILE" "${FRAMEWORK}.o" \
    -sdk "$SDK_ROOT" \
    -F "$PRIVATE_FRAMEWORKS" \
    -framework "$FRAMEWORK" \
    -o "${FRAMEWORK}_test_run"

echo "--- Codesigning ---"
codesign --force --options runtime --verbose -s - "${FRAMEWORK}_test_run"

echo "--- Running Test ---"
./"${FRAMEWORK}_test_run"
