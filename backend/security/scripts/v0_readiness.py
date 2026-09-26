#!/usr/bin/env python3
"""Build the fail-closed V0 release verdict from reproducible evidence."""

from __future__ import annotations

import argparse
import datetime as dt
import json
from pathlib import Path


def load(path: Path) -> dict:
    if not path.is_file():
        return {}
    try:
        value = json.loads(path.read_text())
    except (OSError, json.JSONDecodeError):
        return {}
    return value if isinstance(value, dict) else {}


def evaluate(reports: Path) -> list[dict[str, str]]:
    checks: list[dict[str, str]] = []

    def record(name: str, passed: bool, evidence: str) -> None:
        checks.append({"name": name, "status": "PASS" if passed else "MISSING_OR_FAILED", "evidence": evidence})

    backup = load(reports / "backup-restore.json")
    record(
        "postgres-backup-restore",
        backup.get("status") == "PASS" and backup.get("sourceTables") == backup.get("restoredTables"),
        "backup-restore.json",
    )
    for dependency in ("postgres", "redis"):
        result = load(reports / f"resilience-{dependency}.json")
        record(
            f"{dependency}-loss-recovery",
            result.get("status") == "PASS" and result.get("phase") == "recovered" and result.get("outageObserved") is True,
            f"resilience-{dependency}.json",
        )

    probe = load(reports / "api-security-probe.json")
    probe_findings = probe.get("findings", [])
    record(
        "unauthenticated-api-probes",
        bool(probe_findings) and all(item.get("passed") is True for item in probe_findings if isinstance(item, dict)),
        "api-security-probe.json",
    )

    finding_report = load(reports / "findings.json")
    findings = finding_report.get("findings", [])
    blockers = [
        item for item in findings
        if isinstance(item, dict) and item.get("confirmed") is True and item.get("severity") in {"HIGH", "CRITICAL"}
    ]
    record(
        "confirmed-high-critical-findings",
        bool(finding_report) and isinstance(findings, list) and not blockers,
        "findings.json",
    )

    for name, filename in (
        ("ai-job-restart-recovery", "ai-restart.json"),
        ("prompt-token-log-trace-leak", "sensitive-observability.json"),
    ):
        result = load(reports / filename)
        record(name, result.get("status") == "PASS", filename)
    return checks


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--reports", type=Path, default=Path("security/reports"))
    parser.add_argument("--output", type=Path, default=Path("security/reports/v0-readiness.json"))
    parser.add_argument("--gate", action="store_true")
    args = parser.parse_args()
    checks = evaluate(args.reports)
    ready = all(item["status"] == "PASS" for item in checks)
    result = {
        "schemaVersion": 1,
        "generatedAt": dt.datetime.now(dt.timezone.utc).isoformat(),
        "release": "NEXUS-V0",
        "status": "READY" if ready else "NOT_READY",
        "checks": checks,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + "\n")
    print(f"V0 {result['status']}: {sum(c['status'] == 'PASS' for c in checks)}/{len(checks)} gates passed")
    return 2 if args.gate and not ready else 0


if __name__ == "__main__":
    raise SystemExit(main())
