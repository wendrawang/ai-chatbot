# Created by Wendra on 16/10/26.
"""Active prototype sources; legacy files stay on disk pending owner selection."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent

def package_sources(package, target):
    manifest = (ROOT / package / 'Package.swift').read_text()
    match = re.search(r'exclude:\s*\[(.*?)\]', manifest, re.S)
    excluded = set(re.findall(r'"([^"]+)"', match.group(1))) if match else set()
    folder = ROOT / package / 'Sources' / target
    return [p for p in folder.rglob('*.swift')
            if p.relative_to(folder).as_posix() not in excluded and '/Generated/' not in str(p)]

def sources():
    paths = package_sources('Packages/DesignKit', 'DesignKit')
    paths += package_sources('Packages/TanyaAI', 'TanyaAIDomain')
    paths += list((ROOT / 'Packages/TanyaAI/Sources/TanyaAIFeature').rglob('*.swift'))
    paths += list((ROOT / 'Examples/TanyaAIHarness/Sources').rglob('*.swift'))
    paths += list((ROOT / 'Packages/TanyaAI/Tests/TanyaAIFeatureTests').glob('*.swift'))
    paths += list((ROOT / 'Packages/DesignKit/Tests/PrototypeTests').glob('*.swift'))
    paths += list((ROOT / 'TanyaAISandboxUITests').glob('Prototype*.swift'))
    paths += [ROOT / 'TanyaAISandboxApp' / name for name in ['AppDelegate.swift', 'SceneDelegate.swift']]
    paths += [ROOT / name / 'Package.swift' for name in ['Packages/DesignKit', 'Packages/TanyaAI', 'Examples/TanyaAIHarness']]
    paths += [ROOT / 'Scripts/check_methods.swift']
    return sorted(set(paths))

if __name__ == '__main__':
    print('\n'.join(str(p) for p in sources()))
