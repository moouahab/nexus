import json
import tempfile
import unittest
from pathlib import Path

from security.scripts.normalize_findings import apply_triage, load_reports


class NormalizeFindingsTest(unittest.TestCase):
    def test_semgrep_is_normalized_and_deduplicated(self):
        with tempfile.TemporaryDirectory() as directory:
            reports = Path(directory)
            result = {"check_id": "nexus.rule", "path": "services/projects/a.dart", "start": {"line": 7},
                      "extra": {"message": "unsafe", "severity": "ERROR", "metadata": {"cwe": "CWE-1"}}}
            (reports / "semgrep.json").write_text(json.dumps({"results": [result, result]}))
            findings = load_reports(reports)
            self.assertEqual(1, len(findings))
            self.assertEqual("HIGH", findings[0]["severity"])
            self.assertFalse(findings[0]["confirmed"])

    def test_only_explicit_triage_confirms(self):
        findings = [{"fingerprint": "abc", "confirmed": False}]
        with tempfile.TemporaryDirectory() as directory:
            triage = Path(directory) / "triage.json"
            triage.write_text(json.dumps({"findings": [{"fingerprint": "abc", "status": "confirmed", "owner": "security"}]}))
            apply_triage(findings, triage)
        self.assertTrue(findings[0]["confirmed"])

    def test_probe_keeps_only_failed_assertions_as_confirmed_findings(self):
        with tempfile.TemporaryDirectory() as directory:
            reports = Path(directory)
            (reports / "api-security-probe.json").write_text(json.dumps({"findings": [
                {"check": "missing-auth:projects:GET:/v1/projects", "severity": "critical", "passed": False, "evidence": "HTTP 200"},
                {"check": "trace-method", "severity": "medium", "passed": True, "evidence": "HTTP 405"},
            ]}))
            findings = load_reports(reports)
            self.assertEqual(1, len(findings))
            self.assertEqual("missing-auth:projects:GET:/v1/projects", findings[0]["finding"])
            self.assertTrue(findings[0]["confirmed"])
            self.assertEqual("projects", findings[0]["service"])


if __name__ == "__main__":
    unittest.main()
