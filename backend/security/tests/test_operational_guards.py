import subprocess
import os
import json
import tempfile
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

    def test_dependency_resilience_refuses_non_test_database(self):
        result = subprocess.run(
            ["bash", "security/scripts/dependency_resilience_test.sh", "postgres",
             "projects_server-postgres-1", "http://127.0.0.1:8000/health"],
            capture_output=True, text=True,
        )
        self.assertEqual(64, result.returncode)

    def test_dependency_resilience_rejects_mismatched_dependency(self):
        result = subprocess.run(
            ["bash", "security/scripts/dependency_resilience_test.sh", "redis",
             "nexus-security-postgres_test-1", "http://127.0.0.1:8000/health"],
            capture_output=True, text=True,
        )
        self.assertEqual(64, result.returncode)

    def test_dependency_resilience_dry_run_writes_json_without_docker(self):
        environment = os.environ.copy()
        environment.pop("NEXUS_RESILIENCE_EXECUTE", None)
        with tempfile.TemporaryDirectory() as directory:
            report = os.path.join(directory, "redis.json")
            result = subprocess.run(
                ["bash", "security/scripts/dependency_resilience_test.sh", "redis",
                 "nexus-security-redis_test-1", "http://127.0.0.1:8000/health", report],
                capture_output=True, text=True, env=environment,
            )
            self.assertEqual(0, result.returncode, result.stderr)
            self.assertIn("DRY-RUN", result.stdout)
            with open(report, encoding="utf-8") as report_file:
                payload = json.load(report_file)
            self.assertEqual("DRY_RUN", payload["status"])
            self.assertEqual("redis-temporary-loss", payload["scenario"])

    def test_dependency_resilience_execution_requires_disposable_ack(self):
        environment = os.environ.copy()
        environment["NEXUS_RESILIENCE_EXECUTE"] = "true"
        environment.pop("NEXUS_DISPOSABLE_STACK", None)
        environment["NEXUS_DISPOSABLE_PROJECT"] = "nexus-security"
        result = subprocess.run(
            ["bash", "security/scripts/dependency_resilience_test.sh", "postgres",
             "nexus-security-postgres_test-1", "http://127.0.0.1:8000/health"],
            capture_output=True, text=True, env=environment,
        )
        self.assertEqual(64, result.returncode)
        self.assertIn("acknowledgement", result.stderr)


if __name__ == "__main__":
    unittest.main()
