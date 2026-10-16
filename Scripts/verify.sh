#!/bin/sh
# Created by Wendra on 16/10/26.
set -eu
PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
"$PROJECT_ROOT/Scripts/check_style.sh"
python3 "$PROJECT_ROOT/Scripts/test_core.py"
ruby "$PROJECT_ROOT/Scripts/generate_project.rb"
xcodebuild -project "$PROJECT_ROOT/TanyaAISandbox.xcodeproj" -scheme TanyaAISandbox \
  -destination 'generic/platform=iOS Simulator' -skipPackagePluginValidation \
  CODE_SIGNING_ALLOWED=NO build-for-testing -quiet
if [ -n "${TANYA_AI_TEST_DESTINATION:-}" ]; then
  xcodebuild -project "$PROJECT_ROOT/TanyaAISandbox.xcodeproj" -scheme TanyaAISandbox \
    -destination "$TANYA_AI_TEST_DESTINATION" -skipPackagePluginValidation \
    -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO test -quiet
else
  echo 'UI tests compiled only. Set TANYA_AI_TEST_DESTINATION to run them on a compatible simulator.'
fi
