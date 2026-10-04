#!/usr/bin/env python3
"""Guard UI literals and resource contracts in production packages.

Protocol strings, identifiers, symbols, empty text and arithmetic are not UI copy.
Fixture/test data and the token definitions themselves are deliberately excluded.
This is a focused regression guard, not a substitute for a design/code review.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PACKAGES = ROOT / "Packages"
errors = []


def report(path, line, message):
    errors.append(f"{path.relative_to(ROOT)}:{line}: {message}")


def sources():
    for path in sorted(PACKAGES.glob("*/Sources/**/*.swift")):
        if any(part in path.parts for part in ("Generated", "TanyaAITestSupport")):
            continue
        yield path


# Match a literal at the UI API boundary, including multiline calls.
NUMBER = r"(?:0\.[0-9]*[1-9][0-9]*|[1-9][0-9]*(?:\.[0-9]+)?)\b(?!%)"
SIZE_RULES = [
    rf"(?:spacing|lineWidth|cornerRadius|minLength|minWidth|maxWidth|width|height|minHeight|maxHeight):\s*{NUMBER}",
    rf"\.(?:padding|cornerRadius)\(\s*(?:\.[a-zA-Z]+,\s*)?{NUMBER}",
    rf"artwork\.(?:size|stroke|tapTarget)\(\s*{NUMBER}",
    rf"(?:CGFloat\(\s*{NUMBER}\s*\)|\b{NUMBER})\.(?:sizeInArtwork|strokeInArtwork|tapTargetInArtwork)",
    rf"\.system(?:Font)?\((?:ofSize|size):\s*{NUMBER}",
    rf"(?:estimatedRowHeight|rowHeight)\s*=\s*{NUMBER}",
]
TEXT_RULES = [
    r'\b(?:Text|Button|Label)\(\s*"[^"\n]*[A-Za-z][^"\n]*"',
    r'\b(?:accessibilityLabel|accessibilityHint|errorMessage)\s*=\s*"[^"\n]+"',
    r'\b(?:title|detail|placeholder|submitTitle|continueTitle|cancelTitle):\s*String\??\s*=\s*"[^"\n]+"',
]
references = set()
for path in sources():
    original = path.read_text()
    text = "\n".join("" if line.lstrip().startswith("//") else line for line in original.splitlines())
    if "Tokens" not in path.parts:
        for pattern in SIZE_RULES + TEXT_RULES:
            for match in re.finditer(pattern, text):
                # Pure interpolation / bullet prefix is content supplied by the caller.
                if '\\(' in match.group() and not re.search(r'[A-Za-z]', match.group().split('"')[1].split('\\(')[0]):
                    continue
                report(path, text.count("\n", 0, match.start()) + 1, "Use tokens or localized/injected UI copy")
    if "DesignKit" in path.parts:
        if re.search(r"\bimport\s+Tanya|\bTanya\w*", original):
            report(path, 1, "DesignKit must not reference a feature")
    if re.search(r"\\\.artwork\b|\bartworkLayout\(", text):
        report(path, 1, "Use .sizeInArtwork properties; artwork environment/root setup is not supported")
    if re.search(r"(?:struct|class)\s+Tanya\w*\s*:\s*(?:View\b|UIView|UITableView|Shape\b)", text):
        report(path, 1, "Use a generic component name")
    references.update(re.findall(r'copy\.(?:chat|design)\("([^"]+)"', text))

keys = set()
for resources in PACKAGES.glob("*/Sources/*/Resources"):
    tables = {}
    for path in resources.glob("*.lproj/Localizable.strings"):
        entries = re.findall(r'^"([^"]+)"\s*=\s*"(.*)";', path.read_text(), re.MULTILINE)
        table = dict(entries)
        if len(entries) != len(table):
            report(path, 1, "Duplicate localization key")
        tables[path.parent.stem] = table
        keys.update(table)
    english = tables.get("en", {})
    for language, table in tables.items():
        path = resources / f"{language}.lproj/Localizable.strings"
        if set(table) != set(english):
            report(path, 1, "Localization key coverage differs from English")
        for key in set(table) & set(english):
            placeholders = lambda value: set(re.findall(r"\{([a-zA-Z]+)\}", value))
            if placeholders(table[key]) != placeholders(english[key]):
                report(path, 1, f"Placeholder mismatch: {key}")
for key in sorted(references - keys):
    errors.append(f"Missing localized UI key: {key}")

if errors:
    print("\n".join(errors), file=sys.stderr)
    sys.exit(1)
print("Design system checks passed: UI literals, component boundaries, localization keys/placeholders.")
