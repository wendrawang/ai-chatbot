#!/usr/bin/env python3
"""Format/check changed Swift sources with the Xcode formatter, excluding generated tokens."""
import argparse
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--base", help="Git ref to compare with the current checkout")
parser.add_argument("--check", action="store_true", help="Check formatting without writing files")
args = parser.parse_args()
environment = dict(os.environ)
environment.setdefault("DEVELOPER_DIR", "/Applications/Xcode.app/Contents/Developer")

def git_paths(*arguments):
    result = subprocess.check_output(["git", *arguments], cwd=ROOT)
    return result.decode().split("\0")

paths = set(git_paths("diff", "--name-only", "--diff-filter=ACM", "-z", args.base or "HEAD"))
paths.update(git_paths("ls-files", "--others", "--exclude-standard", "-z"))
paths = sorted(path for path in paths if path.endswith(".swift")
               and "Generated" not in Path(path).parts and (ROOT / path).is_file())
if paths:
    command = ["xcrun", "swift-format", "lint" if args.check else "format"]
    command += ["--strict"] if args.check else ["--in-place"]
    command += ["--configuration", str(ROOT / ".swift-format"), *paths]
    subprocess.run(command, cwd=ROOT, env=environment, check=True)
print(f"{'Checked' if args.check else 'Formatted'} {len(paths)} Swift files; generated tokens excluded.")
