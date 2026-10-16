#!/bin/sh
# Created by Wendra on 16/10/26.
set -eu
PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
python3 "$PROJECT_ROOT/Scripts/check_prototype.py"
