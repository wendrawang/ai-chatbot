#!/bin/sh

set -eu

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export DEVELOPER_DIR

# A device name alone defaults to the latest SDK runtime, which may not contain
# that model. Select an installed destination, or let CI supply an explicit one.
TEST_DESTINATION="${TANYA_AI_TEST_DESTINATION:-$(python3 "$PROJECT_ROOT/Scripts/simulator_destination.py")}"
printf 'Testing on %s\n' "$TEST_DESTINATION"

ruby "$PROJECT_ROOT/Scripts/generate_project.rb"
"$PROJECT_ROOT/Scripts/check_style.sh"
sh "$PROJECT_ROOT/Scripts/test_tencent_group_adapter.sh"
python3 -m unittest discover \
  -s "$PROJECT_ROOT/Examples/VendorChatSDK/Tencent/Tests" -p 'test_*.py' -v

xcodebuild \
  -project "$PROJECT_ROOT/TanyaAISandbox.xcodeproj" \
  -scheme TanyaAISandbox \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build \
  -quiet

# DesignKit is its own package now, so its tests need their own run: the
# feature package's scheme does not carry them.
cd "$PROJECT_ROOT/Packages/DesignKit"
xcodebuild \
  -scheme DesignKit \
  -destination "$TEST_DESTINATION" \
  -parallel-testing-enabled NO \
  CODE_SIGNING_ALLOWED=NO \
  -enableCodeCoverage YES \
  test \
  -quiet

cd "$PROJECT_ROOT/Packages/TanyaAI"
xcodebuild \
  -scheme TanyaAI-Package \
  -destination "$TEST_DESTINATION" \
  -parallel-testing-enabled NO \
  CODE_SIGNING_ALLOWED=NO \
  -enableCodeCoverage YES \
  test \
  -quiet

cd "$PROJECT_ROOT"
xcodebuild \
  -project "$PROJECT_ROOT/TanyaAISandbox.xcodeproj" \
  -scheme TanyaAISandbox \
  -destination "$TEST_DESTINATION" \
  -parallel-testing-enabled NO \
  CODE_SIGNING_ALLOWED=NO \
  -enableCodeCoverage YES \
  test \
  -quiet
