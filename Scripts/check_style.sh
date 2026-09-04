#!/bin/sh

set -eu

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
MAXIMUM_LINES=250

# SwiftLint loads sourcekitd out of the toolchain, so it needs a real Xcode
# even when xcode-select still points at the Command Line Tools. verify.sh
# exports the same default; repeated here so a direct run behaves the same.
DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export DEVELOPER_DIR

find "$PROJECT_ROOT/TanyaAISandboxApp" \
  "$PROJECT_ROOT/TanyaAISandboxUITests" \
  "$PROJECT_ROOT/Packages/TanyaAI/Sources" \
  "$PROJECT_ROOT/Packages/TanyaAI/Tests" \
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
  echo "SwiftLint is not installed; file-length guard passed."
fi
