#!/bin/sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
export DEVELOPER_DIR=${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}
TEST_ROOT=$(mktemp -d)
trap 'rm -rf "$TEST_ROOT"' 0
CONTRACTS="$PROJECT_ROOT/Packages/TanyaAI/Sources/TanyaAIContracts"
TENCENT_EXAMPLE="$PROJECT_ROOT/Examples/VendorChatSDK/Tencent"

# Build the actual SDK-neutral contracts under the facade name used by the adapter.
xcrun swiftc -swift-version 5 -emit-library -emit-module -module-name TanyaAI \
  "$CONTRACTS"/*.swift -o "$TEST_ROOT/libTanyaAI.dylib" \
  -emit-module-path "$TEST_ROOT/TanyaAI.swiftmodule"
xcrun swiftc -swift-version 5 -emit-library -emit-module -module-name ImSDK_Plus_Swift \
  "$TENCENT_EXAMPLE/Tests/SDKDouble.swift" -o "$TEST_ROOT/libImSDK_Plus_Swift.dylib" \
  -emit-module-path "$TEST_ROOT/ImSDK_Plus_Swift.swiftmodule"
python3 - "$TENCENT_EXAMPLE/TencentChatLifecycle.swift" "$TEST_ROOT/Errors.swift" <<'PY'
import sys
from pathlib import Path
source = Path(sys.argv[1]).read_text()
Path(sys.argv[2]).write_text(source[source.index("enum TencentChatError:"):])
PY
xcrun swiftc -swift-version 5 -I "$TEST_ROOT" -L "$TEST_ROOT" \
  -lTanyaAI -lImSDK_Plus_Swift -Xlinker -rpath -Xlinker "$TEST_ROOT" \
  "$TENCENT_EXAMPLE/TencentChatSessionAdapter.swift" \
  "$TENCENT_EXAMPLE/TencentChatSessionAdapter+Contract.swift" \
  "$TEST_ROOT/Errors.swift" "$TENCENT_EXAMPLE/Tests/main.swift" -o "$TEST_ROOT/group-tests"
"$TEST_ROOT/group-tests"
