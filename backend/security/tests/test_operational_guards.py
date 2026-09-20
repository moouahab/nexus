import subprocess
import os
import unittest


class OperationalGuardsTest(unittest.TestCase):
    def test_backup_refuses_production_like_target(self):
        result = subprocess.run(
            ["bash", "security/scripts/backup_restore_test.sh", "projects-postgres-1", "projects", "/tmp/never.json"],
            capture_output=True, text=True,
        )
        self.assertEqual(64, result.returncode)

    def test_resilience_refuses_non_test_container(self):
        result = subprocess.run(
            ["bash", "security/scripts/resilience_test.sh", "projects_server-api-1", "http://127.0.0.1:8000/health"],
            capture_output=True, text=True,
        )
        self.assertEqual(64, result.returncode)

    def test_resilience_is_dry_run_by_default(self):
        environment = os.environ.copy()
        environment.pop("NEXUS_RESILIENCE_EXECUTE", None)
        result = subprocess.run(
            ["bash", "security/scripts/resilience_test.sh", "projects_server-api_test-1", "http://127.0.0.1:8000/health"],
            capture_output=True, text=True, env=environment,
        )
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertIn("DRY-RUN", result.stdout)


if __name__ == "__main__":
    unittest.main()
