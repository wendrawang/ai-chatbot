#!/bin/sh

set -eu

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
MAXIMUM_LINES=250

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

FORBIDDEN_SWIFTUI_PATTERN='import UIKit|UIViewRepresentable|UIViewController|UINavigationController|UIHostingController|UITableView|NavigationView|NavigationLink'
if rg -n "$FORBIDDEN_SWIFTUI_PATTERN" \
  "$PROJECT_ROOT/Packages/TanyaAI/Sources"; then
  echo "Production package must remain pure SwiftUI."
  exit 1
fi

if rg -n "iOS 13|\.iOS\(\.v13\)|IPHONEOS_DEPLOYMENT_TARGET.*13\.0" \
  "$PROJECT_ROOT/Packages/TanyaAI/Package.swift" \
  "$PROJECT_ROOT/Scripts/generate_project.rb"; then
  echo "Deployment target must remain iOS 16 or newer."
  exit 1
fi

if command -v swiftlint >/dev/null 2>&1; then
  swiftlint lint \
    --config "$PROJECT_ROOT/.swiftlint.yml" \
    --strict
else
  echo "SwiftLint is not installed; file-length guard passed."
fi
