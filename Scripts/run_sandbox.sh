#!/bin/sh

# Builds the sandbox, installs it on a booted simulator, and launches it.
#
# Any argument is forwarded to the app, so the launch modes work directly:
#
#   ./Scripts/run_sandbox.sh                 legacy host screen
#   ./Scripts/run_sandbox.sh --deeplink      hand-off demo
#   ./Scripts/run_sandbox.sh --showcase      every bubble
#   ./Scripts/run_sandbox.sh --stress-chat   5,000 messages
#
# Override the device with TANYA_AI_SIMULATOR.

set -eu

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
DERIVED_DATA_ROOT="${TANYA_AI_DERIVED_DATA_ROOT:-/tmp/TanyaAI-Run}"
SIMULATOR="${TANYA_AI_SIMULATOR:-iPhone 17 Pro}"
BUNDLE_IDENTIFIER="com.example.tanyaai.sandbox"
export DEVELOPER_DIR

ruby "$PROJECT_ROOT/Scripts/generate_project.rb"

xcrun simctl boot "$SIMULATOR" 2>/dev/null || true
open -a Simulator

xcodebuild \
  -project "$PROJECT_ROOT/TanyaAISandbox.xcodeproj" \
  -scheme TanyaAISandbox \
  -destination "platform=iOS Simulator,name=$SIMULATOR" \
  -derivedDataPath "$DERIVED_DATA_ROOT" \
  CODE_SIGNING_ALLOWED=NO \
  build \
  -quiet

APP_PATH="$DERIVED_DATA_ROOT/Build/Products/Debug-iphonesimulator/Tanya AI Sandbox.app"

xcrun simctl install booted "$APP_PATH"
xcrun simctl terminate booted "$BUNDLE_IDENTIFIER" 2>/dev/null || true
xcrun simctl launch --console-pty booted "$BUNDLE_IDENTIFIER" "$@"
