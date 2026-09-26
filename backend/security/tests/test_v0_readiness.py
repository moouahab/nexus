import json
import tempfile
import unittest
from pathlib import Path

from security.scripts.v0_readiness import evaluate


class V0ReadinessTest(unittest.TestCase):
    def test_fails_closed_when_final_evidence_is_missing(self):
        with tempfile.TemporaryDirectory() as directory:
            checks = evaluate(Path(directory))
        self.assertTrue(checks)
        self.assertTrue(all(item["status"] == "MISSING_OR_FAILED" for item in checks))

    def test_accepts_complete_reproducible_evidence(self):
        with tempfile.TemporaryDirectory() as directory:
            reports = Path(directory)
            values = {
                "backup-restore.json": {"status": "PASS", "sourceTables": 2, "restoredTables": 2},
                "resilience-postgres.json": {"status": "PASS", "phase": "recovered", "outageObserved": True},
                "resilience-redis.json": {"status": "PASS", "phase": "recovered", "outageObserved": True},
                "api-security-probe.json": {"findings": [{"passed": True}]},
                "findings.json": {"findings": []},
                "ai-restart.json": {"status": "PASS"},
                "sensitive-observability.json": {"status": "PASS"},
            }
            for name, value in values.items():
                (reports / name).write_text(json.dumps(value))
            checks = evaluate(reports)
        self.assertTrue(all(item["status"] == "PASS" for item in checks))


if __name__ == "__main__":
    unittest.main()
