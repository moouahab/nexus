import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))

import api_security_probe as probe  # noqa: E402


class ApiSecurityProbeTest(unittest.TestCase):
    def test_inventory_covers_every_service_and_has_unique_operations(self):
        operations = probe.PROTECTED_OPERATIONS

        self.assertEqual(
            {operation.service for operation in operations},
            {"identity", "users", "parties", "projects", "ai"},
        )
        identities = {
            (operation.method, operation.path) for operation in operations
        }
        self.assertEqual(len(identities), len(operations))
        self.assertEqual(len(operations), 35)

    def test_concrete_path_replaces_path_and_query_placeholders(self):
        result = probe.concrete_path(
            "/v1/projects/{projectId}/ai-access?tenantPartyId={tenantPartyId}"
        )

        self.assertNotIn("{", result)
        self.assertEqual(result.count(probe._PLACEHOLDER_VALUE), 2)

    def test_main_checks_missing_and_malformed_auth_for_every_operation(self):
        calls = []

        def fake_request(target, path, method="GET", headers=None):
            calls.append((target, path, method, headers))
            if method == "TRACE":
                return 405, {}, b""
            if path in {
                "/v1/auth/health",
                "/.well-known/jwks.json",
                "/v1/ai/health",
            }:
                return 200, {"X-Request-Id": "test"}, b"{}"
            return 401, {}, b'{"error":"unauthorized"}'

        with tempfile.TemporaryDirectory() as directory:
            report = Path(directory) / "probe.json"
            with patch.object(probe, "request", side_effect=fake_request), patch.object(
                sys,
                "argv",
                ["api_security_probe.py", "http://127.0.0.1:8000", str(report)],
            ):
                self.assertEqual(probe.main(), 0)

            findings = json.loads(report.read_text(encoding="utf-8"))["findings"]

        checks = {finding["check"] for finding in findings}
        for operation in probe.PROTECTED_OPERATIONS:
            suffix = f"{operation.service}:{operation.method}:{operation.path}"
            self.assertIn(f"missing-auth:{suffix}", checks)
            self.assertIn(f"malformed-jwt:{suffix}", checks)

        protected_calls = [
            call for call in calls if call[1].startswith("/v1/") and call[1] not in {
                "/v1/auth/health",
                "/v1/ai/health",
            }
        ]
        self.assertEqual(len(protected_calls), len(probe.PROTECTED_OPERATIONS) * 2)


if __name__ == "__main__":
    unittest.main()
