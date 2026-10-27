#!/bin/sh
#
#  generate_resources.sh
#  ai-chatbot
#
#  Created by Wendra on 27/10/26.
#

# R.swift dijalankan manual lalu hasilnya di-commit, bukan sebagai build tool
# plugin, supaya CI host tidak gagal di validasi plugin (Trust & Enable).
# Jalankan ulang setiap kali asset, font, atau string berubah.

set -eu

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export DEVELOPER_DIR
OUTPUT_PATH="Generated/R.generated.swift"

# Package memakai command plugin R.swift agar daftar resource sama dengan target SwiftPM.
generate_package() {
  package_name="$1"
  shift
  package_path="$PROJECT_ROOT/Packages/$package_name"
  mkdir -p "$package_path/Sources/$package_name/Generated"
  swift package --package-path "$package_path" plugin --allow-writing-to-package-directory \
    rswift-generate-resources --target "$package_name" "$OUTPUT_PATH" "$@"
}

generate_package DesignKit --access-level public
generate_package TanyaAI

# Target app sandbox bukan target SwiftPM, jadi CLI rswift dipanggil langsung
# dengan resource yang sama seperti di generate_project.rb.
TOOL_PACKAGE="$PROJECT_ROOT/Packages/TanyaAI"
swift build --package-path "$TOOL_PACKAGE" --product rswift >/dev/null
RSWIFT="$(swift build --package-path "$TOOL_PACKAGE" --show-bin-path)/rswift"
APP_PATH="$PROJECT_ROOT/TanyaAISandboxApp"
mkdir -p "$APP_PATH/Generated"
"$RSWIFT" generate "$APP_PATH/$OUTPUT_PATH" \
  --input-type input-files \
  --bundle-source finder \
  --input-files "$APP_PATH/LaunchScreen.storyboard" \
  --input-files "$APP_PATH/Resources/en.lproj/Localizable.strings" \
  --input-files "$APP_PATH/Resources/id.lproj/Localizable.strings" \
  --input-files "$APP_PATH/Resources/zh-Hans.lproj/Localizable.strings"

echo "Generated R.swift accessors for DesignKit, TanyaAI and TanyaAISandbox."
