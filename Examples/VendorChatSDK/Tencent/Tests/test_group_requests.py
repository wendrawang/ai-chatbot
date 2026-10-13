"""Offline group REST routing/schema tests. No requests reach Tencent."""
import importlib.util
import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

EXAMPLE = Path(__file__).resolve().parent.parent
SPEC = importlib.util.spec_from_file_location("builder", EXAMPLE / "build_test_message.py")
BUILDER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(BUILDER)


class GroupRequestTests(unittest.TestCase):
    def setUp(self):
        self.values = {"TENCENT_GROUP_ID": "group-wen", "TENCENT_MESSAGE_RANDOM": "123"}

    def test_all_fixtures_use_group_envelope(self):
        for scenario in BUILDER.SCENARIOS:
            with self.subTest(scenario=scenario):
                request = BUILDER.build_request(scenario, self.values)
                self.assertEqual(request["GroupId"], "group-wen")
                self.assertEqual(request["From_Account"], "bot_poc")
                self.assertEqual(request["Random"], 123)
                self.assertEqual(request["OnlineOnlyFlag"], 0)
                self.assertFalse({"To_Account", "MsgRandom", "SyncOtherMachine"} & request.keys())
                expected = json.loads((EXAMPLE / "Fixtures" / f"{scenario}.json").read_text())
                self.assertEqual(request["MsgBody"], expected)

    def test_create_group_provisions_customer_and_bot(self):
        request = BUILDER.build_request("create-group", self.values)
        self.assertEqual(request["Type"], "Public")
        self.assertEqual(request["ApplyJoinOption"], "DisableApply")
        self.assertEqual(request["InviteJoinOption"], "DisableInvite")
        self.assertEqual(request["Owner_Account"], "wen")
        self.assertEqual(request["MemberList"], [{"Member_Account": "bot_poc"}])
        self.assertEqual(request["GroupId"], "group-wen")
        self.values.update(TENCENT_USER_ID="customer", TENCENT_BOT_ID="assistant")
        request = BUILDER.build_request("create-group", self.values)
        self.assertEqual(request["Owner_Account"], "customer")
        self.assertEqual(request["MemberList"], [{"Member_Account": "assistant"}])

    def test_invalid_inputs_fail_before_request(self):
        for group in ("", " "):
            with self.assertRaises(ValueError):
                BUILDER.build_request("text", {**self.values, "TENCENT_GROUP_ID": group})
        for random in ("-1", "4294967296", "invalid"):
            with self.assertRaises(ValueError):
                BUILDER.build_request("text", {**self.values, "TENCENT_MESSAGE_RANDOM": random})
        with self.assertRaises(ValueError):
            BUILDER.build_request("unknown", self.values)
        with self.assertRaises(ValueError):
            BUILDER.build_request("create-group", {**self.values, "TENCENT_USER_ID": "bot_poc"})
        self.assertEqual(BUILDER.build_request("text", {**self.values, "TENCENT_MESSAGE_RANDOM": "0"})["Random"], 0)

    def run_script(self, scenario, extra):
        environment = {key: value for key, value in os.environ.items() if not key.startswith("TENCENT_")}
        environment.update(self.values)
        environment.update(extra)
        return subprocess.run(
            ["sh", str(EXAMPLE / "send_test_reply.sh"), scenario],
            env=environment, capture_output=True, text=True, timeout=10,
        )

    def test_dry_run_needs_no_credentials(self):
        for scenario in ("answer", "create-group"):
            result = self.run_script(scenario, {"TENCENT_DRY_RUN": "1"})
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(json.loads(result.stdout)["GroupId"], "group-wen")
        result = self.run_script("text", {"TENCENT_GROUP_ID": ""})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("TENCENT_GROUP_ID", result.stderr)

    def test_shell_routes_and_checks_application_errors(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            curl = folder / "curl"
            curl.write_text("""#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
arguments = sys.argv[1:]
body_path = arguments[arguments.index('--data-binary') + 1][1:]
Path(os.environ['TENCENT_RECORD_FILE']).write_text(json.dumps({
    'arguments': arguments, 'body': json.loads(Path(body_path).read_text())
}))
print(os.environ['TENCENT_FAKE_RESPONSE'])
""")
            curl.chmod(0o755)
            environment = {
                "PATH": directory + os.pathsep + os.environ["PATH"],
                "TENCENT_SDK_APP_ID": "1", "TENCENT_REST_HOST": "example.invalid",
                "TENCENT_ADMIN_SIG": "offline-test-signature",
                "TENCENT_RECORD_FILE": str(folder / "request.json"),
                "TENCENT_FAKE_RESPONSE": '{"ActionStatus":"OK","ErrorCode":0}',
            }
            for scenario, endpoint in (("answer", "send_group_msg"), ("create-group", "create_group")):
                result = self.run_script(scenario, environment)
                self.assertEqual(result.returncode, 0, result.stderr)
                record = json.loads((folder / "request.json").read_text())
                arguments = record["arguments"]
                url = arguments[arguments.index("--url") + 1]
                self.assertEqual(url, "https://example.invalid/v4/group_open_http_svc/" + endpoint)
                self.assertEqual(record["body"]["GroupId"], "group-wen")
            for response in (
                '{"ActionStatus":"FAIL","ErrorCode":10007}',
                '{"ActionStatus":"OK","ErrorCode":1}',
                '{"ActionStatus":"OK","ErrorCode":false}', "not-json", "[]",
            ):
                result = self.run_script("text", {**environment, "TENCENT_FAKE_RESPONSE": response})
                self.assertNotEqual(result.returncode, 0, response)
                self.assertIn("Tencent rejected", result.stderr)


if __name__ == "__main__":
    unittest.main()
