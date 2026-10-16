#!/bin/sh

# Created by Wendra on 16/10/26.
# Requires a simulator runtime compatible with the selected Xcode.
# ./Scripts/run_sandbox.sh --chat --language id --scenario success
# Scenarios: success, inquiryFailure, pinRejection, pending, duplicateIntent, lateInquiry.

set -eu

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
DERIVED_DATA_ROOT="${TANYA_AI_DERIVED_DATA_ROOT:-/tmp/TanyaAI-Run}"
BUNDLE_IDENTIFIER="com.example.tanyaai.sandbox"
export DEVELOPER_DIR
SIMULATOR_DESTINATION="$(python3 "$PROJECT_ROOT/Scripts/simulator_destination.py")"
SIMULATOR_ID="${SIMULATOR_DESTINATION##*id=}"

ruby "$PROJECT_ROOT/Scripts/generate_project.rb"

xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true
xcrun simctl bootstatus "$SIMULATOR_ID" -b
open -a Simulator

xcodebuild \
  -project "$PROJECT_ROOT/TanyaAISandbox.xcodeproj" \
  -scheme TanyaAISandbox \
  -destination "$SIMULATOR_DESTINATION" \
  -derivedDataPath "$DERIVED_DATA_ROOT" \
  -skipPackagePluginValidation \
  CODE_SIGNING_ALLOWED=NO \
  build \
  -quiet

APP_PATH="$DERIVED_DATA_ROOT/Build/Products/Debug-iphonesimulator/Tanya AI Sandbox.app"

xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"
xcrun simctl terminate "$SIMULATOR_ID" "$BUNDLE_IDENTIFIER" 2>/dev/null || true
xcrun simctl launch --console-pty "$SIMULATOR_ID" "$BUNDLE_IDENTIFIER" "$@"
