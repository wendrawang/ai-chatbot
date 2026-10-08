#!/usr/bin/env python3
"""Build a REST request from the checked-in MsgBody contract, without credentials."""
import json
import os
import sys
from pathlib import Path

SCENARIOS = ("text", "radio", "info", "link", "confirmation", "answer")
scenario = sys.argv[1] if len(sys.argv) > 1 else "text"
if scenario not in SCENARIOS:
    raise SystemExit("Choose: " + ", ".join(SCENARIOS))
body = json.loads((Path(__file__).parent / "Fixtures" / f"{scenario}.json").read_text())
request = {
    "SyncOtherMachine": 2,
    "From_Account": os.environ.get("TENCENT_BOT_ID", "bot_poc"),
    "To_Account": os.environ.get("TENCENT_USER_ID", "wen"),
    "MsgRandom": int(os.environ["TENCENT_MESSAGE_RANDOM"]),
    "MsgBody": body,
}
json.dump(request, sys.stdout, ensure_ascii=False)
sys.stdout.write("\n")
