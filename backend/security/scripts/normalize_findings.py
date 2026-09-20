#!/usr/bin/env python3
"""Normalize NEXUS security reports and gate confirmed severe findings."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path
from typing import Any, Iterable


SEVERITY = {"ERROR": "HIGH", "WARNING": "MEDIUM", "NOTE": "LOW"}


def fingerprint(finding: dict[str, Any]) -> str:
    stable = "|".join(str(finding.get(k, "")) for k in ("service", "endpoint", "category", "finding"))
    return hashlib.sha256(stable.encode()).hexdigest()[:20]


def normalized(**values: Any) -> dict[str, Any]:
    item = {
        "finding": values.get("finding", "Unspecified security finding"),
        "severity": str(values.get("severity", "UNKNOWN")).upper(),
        "confidence": str(values.get("confidence", "medium")).lower(),
        "confirmed": bool(values.get("confirmed", False)),
        "service": values.get("service", "unknown"),
        "endpoint": values.get("endpoint"),
        "category": values.get("category", "security"),
        "cwe": values.get("cwe"),
        "owaspApiCategory": values.get("owaspApiCategory"),
        "evidence": values.get("evidence"),
        "reproduction": values.get("reproduction"),
        "recommendation": values.get("recommendation"),
        "tool": values.get("tool", "unknown"),
        "runId": values.get("runId"),
        "timestamp": values.get("timestamp") or dt.datetime.now(dt.timezone.utc).isoformat(),
    }
    item["fingerprint"] = fingerprint(item)
    return item


def semgrep(data: dict[str, Any]) -> Iterable[dict[str, Any]]:
    for result in data.get("results", []):
        extra = result.get("extra", {})
        metadata = extra.get("metadata", {})
        path = result.get("path", "unknown")
        yield normalized(
            finding=extra.get("message") or result.get("check_id"),
            severity=SEVERITY.get(
                str(extra.get("severity", "WARNING")).upper(),
                extra.get("severity", "UNKNOWN"),
            ),
            confidence=metadata.get("confidence", "medium"),
            service=path.split("/")[1] if path.startswith("services/") else "repository",
            endpoint=None, category=metadata.get("category", "sast"), cwe=metadata.get("cwe"),
            owaspApiCategory=metadata.get("owasp-api"),
            evidence=f"{path}:{result.get('start', {}).get('line', '?')}",
            recommendation=metadata.get("fix"), tool="semgrep",
        )


def sarif(data: dict[str, Any], source: str) -> Iterable[dict[str, Any]]:
    for run in data.get("runs", []):
        rules = {r.get("id"): r for r in run.get("tool", {}).get("driver", {}).get("rules", [])}
        for result in run.get("results", []):
            rule = rules.get(result.get("ruleId"), {})
            props = rule.get("properties", {})
            locations = result.get("locations", [])
            physical = locations[0].get("physicalLocation", {}) if locations else {}
            artifact = physical.get("artifactLocation", {}).get("uri", "unknown")
            line = physical.get("region", {}).get("startLine", "?")
            message = result.get("message", {}).get("text") or rule.get("shortDescription", {}).get("text")
            yield normalized(
                finding=message or result.get("ruleId"),
                severity=SEVERITY.get(str(result.get("level", "warning")).upper(), props.get("security-severity", "MEDIUM")),
                service="repository", category="dependency" if source == "trivy" else "secret",
                cwe=props.get("tags"), evidence=f"{artifact}:{line}", tool=source,
            )


def native(data: Any, source: str) -> Iterable[dict[str, Any]]:
    entries = data.get("findings", data) if isinstance(data, dict) else data
    if not isinstance(entries, list):
        return
    for entry in entries:
        if isinstance(entry, dict):
            # Probe reports describe assertions: a failed assertion is a
            # deterministic, confirmed finding; successful assertions are
            # evidence, not findings.
            if "passed" in entry:
                if entry.get("passed") is True:
                    continue
                check = str(entry.get("check", "probe failure"))
                parts = check.split(":")
                service = parts[1] if len(parts) > 2 else "gateway"
                yield normalized(
                    finding=check,
                    severity=entry.get("severity", "UNKNOWN"),
                    confidence="high",
                    confirmed=True,
                    service=service,
                    category=parts[0],
                    evidence=entry.get("evidence"),
                    reproduction=f"Re-run {source}",
                    tool=entry.get("tool", source),
                )
                continue
            yield normalized(**entry, tool=entry.get("tool", source))


def load_reports(report_dir: Path) -> list[dict[str, Any]]:
    findings: list[dict[str, Any]] = []
    for path in sorted(report_dir.glob("*.json")) + sorted(report_dir.glob("*.sarif")):
        if path.name in {"findings.json", "finding-triage.json"}:
            continue
        try:
            data = json.loads(path.read_text())
        except (OSError, json.JSONDecodeError):
            continue
        name = path.stem.lower()
        if "semgrep" in name:
            findings.extend(semgrep(data))
        elif path.suffix == ".sarif":
            findings.extend(sarif(data, "trivy" if "trivy" in name else "gitleaks"))
        else:
            findings.extend(native(data, name))
    unique: dict[str, dict[str, Any]] = {}
    for finding in findings:
        old = unique.get(finding["fingerprint"])
        if old is None or (finding["confirmed"] and not old["confirmed"]):
            unique[finding["fingerprint"]] = finding
    return sorted(unique.values(), key=lambda x: (x["severity"], x["service"], x["finding"]))


def apply_triage(findings: list[dict[str, Any]], triage_path: Path | None) -> None:
    if not triage_path or not triage_path.exists():
        return
    triage = json.loads(triage_path.read_text())
    by_id = {entry["fingerprint"]: entry for entry in triage.get("findings", [])}
    for finding in findings:
        decision = by_id.get(finding["fingerprint"])
        if decision:
            finding["confirmed"] = decision.get("status") == "confirmed"
            finding["triage"] = decision


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--reports", type=Path, default=Path("security/reports"))
    parser.add_argument("--output", type=Path, default=Path("security/reports/findings.json"))
    parser.add_argument("--triage", type=Path, default=Path("security/policy/finding-triage.json"))
    parser.add_argument("--gate", action="store_true")
    args = parser.parse_args()
    findings = load_reports(args.reports)
    apply_triage(findings, args.triage)
    output = {"schemaVersion": 1, "generatedAt": dt.datetime.now(dt.timezone.utc).isoformat(), "findings": findings}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(output, indent=2) + "\n")
    blockers = [f for f in findings if f["confirmed"] and f["severity"] in {"HIGH", "CRITICAL"}]
    print(f"normalized={len(findings)} confirmed_high_critical={len(blockers)} output={args.output}")
    return 2 if args.gate and blockers else 0


if __name__ == "__main__":
    raise SystemExit(main())
