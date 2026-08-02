#!/bin/sh

set -eu

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export DEVELOPER_DIR

ruby "$PROJECT_ROOT/Scripts/generate_project.rb"
"$PROJECT_ROOT/Scripts/check_style.sh"

xcodebuild \
  -project "$PROJECT_ROOT/TanyaAISandbox.xcodeproj" \
  -scheme TanyaAISandbox \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build \
  -quiet

cd "$PROJECT_ROOT/Packages/TanyaAI"
xcodebuild \
  -scheme TanyaAI-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO \
  test \
  -quiet
