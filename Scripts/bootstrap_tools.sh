#!/bin/sh
# Created by Wendra on 16/10/26.
set -eu
PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
mkdir -p "$PROJECT_ROOT/.tools"
curl --fail --location --silent --show-error \
  https://github.com/nicklockwood/SwiftFormat/releases/download/0.63.1/swiftformat.zip \
  -o "$PROJECT_ROOT/.tools/swiftformat.zip"
unzip -oq "$PROJECT_ROOT/.tools/swiftformat.zip" -d "$PROJECT_ROOT/.tools/formatter"
cp "$PROJECT_ROOT/.tools/formatter/swiftformat" "$PROJECT_ROOT/.tools/swiftformat"
chmod +x "$PROJECT_ROOT/.tools/swiftformat"
