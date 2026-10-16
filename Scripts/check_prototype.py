#!/usr/bin/env python3
from pathlib import Path
import os
import subprocess
import sys
from prototype_sources import ROOT, sources

paths = sources()
is_format = '--format' in sys.argv
formatter = ROOT / '.tools/swiftformat'
if not formatter.exists():
    raise SystemExit('Run Scripts/bootstrap_tools.sh first.')
subprocess.run([str(formatter), *map(str, paths), *([] if is_format else ['--lint'])], check=True)
for path in paths:
    source = path.read_text()
    if len(source.splitlines()) > 250:
        raise SystemExit(f'{path}: exceeds 250 physical lines')
    if 'Created by Wendra' not in source:
        raise SystemExit(f'{path}: missing Wendra header')
    if path.parts[-3:-1] == ('TanyaAIDomain', 'Models') and ('import UIKit' in source or 'import SwiftUI' in source):
        raise SystemExit(f'{path}: domain depends on UI')
env = os.environ.copy()
env['SCRIPT_INPUT_FILE_COUNT'] = str(len(paths))
for index, path in enumerate(paths):
    env[f'SCRIPT_INPUT_FILE_{index}'] = str(path)
subprocess.run(['swiftlint', 'lint', '--config', str(ROOT / '.swiftlint.yml'),
                '--use-script-input-files', '--strict', '--no-cache', '--quiet'], env=env, check=True)
swift = subprocess.check_output(['xcrun', '--find', 'swift'], text=True).strip()
host_lib = Path(swift).parent.parent / 'lib/swift/host'
subprocess.run(['xcrun', 'swift', '-I', str(host_lib), '-L', str(host_lib),
                '-lSwiftSyntax', '-lSwiftParser', str(ROOT / 'Scripts/check_methods.swift'),
                *map(str, paths)], check=True)
print(f'Prototype style passed: {len(paths)} Swift files; generated tokens excluded.')
