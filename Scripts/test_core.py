#!/usr/bin/env python3
# Created by Wendra on 16/10/26.
"""Run the unchanged Foundation/Combine flow and parser sources on macOS.

This supplements iOS tests when CoreSimulator is unavailable; it does not test UI.
"""
from pathlib import Path
import hashlib
import shutil
import subprocess

root = Path(__file__).resolve().parent.parent
scratch = root / '.tools' / 'CoreVerification'
domain = root / 'Packages/TanyaAI/Sources/TanyaAIDomain'
feature = root / 'Packages/TanyaAI/Sources/TanyaAIFeature'
tests = root / 'Packages/TanyaAI/Tests/TanyaAIFeatureTests'
groups = {
    'TanyaAIDomain': [
        domain / 'Models' / (name + '.swift') for name in [
            'Money', 'SessionContext', 'TransferDraft', 'TransferQuote',
            'TransferFlowState', 'ConversationModels'
        ]
    ] + [domain / 'Contracts/Services.swift'],
    'TanyaAIFeature': [feature / (name + '.swift') for name in [
        'Transfer/TransferFlowViewModel', 'Transfer/TransferFlowViewModel+Requests', 'Transfer/TransferFlowViewModel+Draft', 'Transfer/Components/PINInput',
        'Rendering/RichTextParser', 'Rendering/RichTextFrame',
        'PublicAPI/TanyaAIDependencies', 'Chat/ChatState', 'Chat/ChatViewModel',
        'Chat/ChatViewModel+Events', 'Chat/FeatureCopy', 'Chat/FeatureCopy+Transfer'
    ]],
    'TanyaAIFeatureTests': [tests / (name + '.swift') for name in [
        'TransferTestServices', 'TransferTestFixture', 'TransferFlowTests',
        'TransferSafetyTests', 'RichTextTests', 'ChatTestServices', 'ChatSafetyTests', 'PINInputTests'
    ]]
}
for target, paths in groups.items():
    folder = scratch / ('Tests' if target.endswith('Tests') else 'Sources') / target
    folder.mkdir(parents=True, exist_ok=True)
    for path in paths:
        shutil.copyfile(path, folder / path.name)
# R.swift 7.8 does not declare resource inputs for incremental rebuilds.
# In this disposable verification workspace, regenerate accessors when the resources change.
digest = hashlib.sha256(b''.join(p.read_bytes() for p in sorted((feature / 'Resources').rglob('*.strings')))).hexdigest()
marker = scratch / 'resource-digest'
if not marker.exists() or marker.read_text() != digest:
    for output in (scratch / '.build').rglob('R.generated.swift'):
        output.unlink()
    marker.write_text(digest)
shutil.copytree(feature / 'Resources', scratch / 'Sources/TanyaAIFeature/Resources', dirs_exist_ok=True)
(scratch / 'Package.swift').write_text('''// swift-tools-version: 5.7
import PackageDescription
let package = Package(name: "CoreVerification", defaultLocalization: "en", platforms: [.macOS(.v13)],
    dependencies: [.package(url: "https://github.com/mac-cain13/R.swift.git", exact: "7.8.0")], targets: [
    .target(name: "TanyaAIDomain"),
    .target(name: "TanyaAIFeature", dependencies: ["TanyaAIDomain", .product(name: "RswiftLibrary", package: "R.swift")],
       resources: [.process("Resources")], plugins: [.plugin(name: "RswiftGenerateInternalResources", package: "R.swift")]),
    .testTarget(name: "TanyaAIFeatureTests", dependencies: ["TanyaAIDomain", "TanyaAIFeature"])
])
''')
subprocess.run(['swift', 'test', '--package-path', str(scratch)], check=True)
