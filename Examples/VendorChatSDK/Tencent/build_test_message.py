#!/usr/bin/env python3
"""Build group REST requests from checked-in contracts, without credentials."""
import json
import os
import sys
from pathlib import Path

SCENARIOS = ("text", "radio", "info", "link", "confirmation", "answer")


def build_request(scenario, environment):
    group_id = environment.get("TENCENT_GROUP_ID", "")
    if not group_id.strip():
        raise ValueError("Set TENCENT_GROUP_ID to the raw Tencent GroupId first.")
    bot_id = environment.get("TENCENT_BOT_ID", "bot_poc")
    if not bot_id.strip():
        raise ValueError("TENCENT_BOT_ID must not be empty.")
    if scenario == "create-group":
        owner_id = environment.get("TENCENT_USER_ID", "wen")
        if not owner_id.strip() or owner_id == bot_id:
            raise ValueError("Set distinct, non-empty customer and bot accounts.")
        return {
            "Owner_Account": owner_id,
            "Type": "Public",
            "ApplyJoinOption": "DisableApply",
            "InviteJoinOption": "DisableInvite",
            "GroupId": group_id,
            "Name": environment.get("TENCENT_GROUP_NAME", "Chat PoC"),
            "MemberList": [{"Member_Account": bot_id}],
        }
    if scenario not in SCENARIOS:
        raise ValueError("Choose: " + ", ".join((*SCENARIOS, "create-group")))
    random = int(environment.get("TENCENT_MESSAGE_RANDOM", "-1"))
    if not 0 <= random <= 0xFFFFFFFF:
        raise ValueError("TENCENT_MESSAGE_RANDOM must be a uint32.")
    body = json.loads((Path(__file__).parent / "Fixtures" / f"{scenario}.json").read_text())
    return {
        "GroupId": group_id,
        "From_Account": bot_id,
        "Random": random,
        "OnlineOnlyFlag": 0,
        "MsgBody": body,
    }


if __name__ == "__main__":
    try:
        request = build_request(sys.argv[1] if len(sys.argv) > 1 else "text", os.environ)
    except ValueError as error:
        raise SystemExit(str(error)) from error
    json.dump(request, sys.stdout, ensure_ascii=False)
    sys.stdout.write("\n")
