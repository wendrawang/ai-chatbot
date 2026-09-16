#!/bin/sh

set -eu

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
MAXIMUM_LINES=250

# SwiftLint loads sourcekitd out of the toolchain, so it needs a real Xcode
# even when xcode-select still points at the Command Line Tools. verify.sh
# exports the same default; repeated here so a direct run behaves the same.
DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export DEVELOPER_DIR

# Every package under Packages/, so a new one is covered the day it appears
# rather than the day someone notices it was not.
find "$PROJECT_ROOT/TanyaAISandboxApp" \
  "$PROJECT_ROOT/TanyaAISandboxUITests" \
  "$PROJECT_ROOT/Packages" \
  "$PROJECT_ROOT/Examples" \
  "$PROJECT_ROOT/Scripts" \
  -type d \( -name .build -o -name .swiftpm -o -name Generated \) -prune -o \
  -name '*.swift' -print0 | while IFS= read -r -d '' source_file; do
    line_count="$(wc -l < "$source_file" | tr -d ' ')"
    if [ "$line_count" -gt "$MAXIMUM_LINES" ]; then
      echo "File exceeds $MAXIMUM_LINES lines: $source_file ($line_count)"
      exit 1
    fi
  done

if command -v swiftlint >/dev/null 2>&1; then
  swiftlint lint \
    --config "$PROJECT_ROOT/.swiftlint.yml" \
    --strict
else
  echo "SwiftLint is required to enforce identifier and boolean naming rules."
  exit 1
fi

# SwiftLint ignores blank/comment lines in method length; enforce physical lines too.
TOOLCHAIN_ROOT="$(dirname "$(dirname "$(xcrun --find swift)")")"
SWIFT_HOST_LIBS="$TOOLCHAIN_ROOT/lib/swift/host"
MACOS_SDK="$(xcrun --sdk macosx --show-sdk-path)"
find "$PROJECT_ROOT/TanyaAISandboxApp" \
  "$PROJECT_ROOT/TanyaAISandboxUITests" \
  "$PROJECT_ROOT/Packages" \
  "$PROJECT_ROOT/Examples" \
  "$PROJECT_ROOT/Scripts" \
  -type d \( -name .build -o -name .swiftpm -o -name Generated \) -prune -o \
  -name '*.swift' -print0 | xargs -0 xcrun swift \
    -sdk "$MACOS_SDK" -I "$SWIFT_HOST_LIBS" -L "$SWIFT_HOST_LIBS" \
    -lSwiftSyntax -lSwiftParser "$PROJECT_ROOT/Scripts/check_methods.swift"
