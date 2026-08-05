#!/bin/sh

set -eu

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
DERIVED_DATA_ROOT="${TANYA_AI_DERIVED_DATA_ROOT:-/tmp/TanyaAI-Verification}"
export DEVELOPER_DIR

ruby "$PROJECT_ROOT/Scripts/generate_project.rb"
"$PROJECT_ROOT/Scripts/check_style.sh"

xcodebuild \
  -project "$PROJECT_ROOT/TanyaAISandbox.xcodeproj" \
  -scheme TanyaAISandbox \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED_DATA_ROOT/AppBuild" \
  CODE_SIGNING_ALLOWED=NO \
  build \
  -quiet

cd "$PROJECT_ROOT/Packages/TanyaAI"
xcodebuild \
  -scheme TanyaAI-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -derivedDataPath "$DERIVED_DATA_ROOT/PackageTests" \
  CODE_SIGNING_ALLOWED=NO \
  -enableCodeCoverage YES \
  test \
  -quiet

cd "$PROJECT_ROOT"
xcodebuild \
  -project "$PROJECT_ROOT/TanyaAISandbox.xcodeproj" \
  -scheme TanyaAISandbox \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -derivedDataPath "$DERIVED_DATA_ROOT/AppTests" \
  CODE_SIGNING_ALLOWED=NO \
  -enableCodeCoverage YES \
  test \
  -quiet
