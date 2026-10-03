#!/usr/bin/env python3
"""Select the newest installed iOS runtime containing the requested device."""
import json
import os
import re
import subprocess
import sys

name = os.environ.get("TANYA_AI_SIMULATOR", "iPhone 17 Pro")
data = json.loads(subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "--json"]))
candidates = []
for runtime, devices in data["devices"].items():
    if ".iOS-" not in runtime:
        continue
    version = tuple(int(part) for part in re.findall(r"\d+", runtime.rsplit("iOS-", 1)[-1]))
    for device in devices:
        if device["name"] == name and device.get("isAvailable", False):
            candidates.append((version, device["udid"]))
if not candidates:
    sys.exit(f"No available iOS simulator named {name!r}. Set TANYA_AI_SIMULATOR or TANYA_AI_TEST_DESTINATION.")
print(f"platform=iOS Simulator,id={max(candidates)[1]}")
