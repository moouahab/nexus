#!/usr/bin/env python3
"""Non-destructive security assertions for the Kong API boundary."""

from __future__ import annotations

import json
import sys
import time
import urllib.error
import urllib.request
from dataclasses import asdict, dataclass
from pathlib import Path

from target_guard import validate_target


@dataclass
class Finding:
    check: str
    severity: str
    passed: bool
    evidence: str


def request(target: str, path: str, method: str = "GET", headers=None):
    req = urllib.request.Request(
        target + path,
        method=method,
        headers=headers or {"Accept": "application/json"},
    )
    # `target` passed the strict HTTP(S) + loopback guard in main; paths below
    # are compile-time constants, so urllib cannot be redirected to file://.
    try:
        # nosemgrep: python.lang.security.audit.dynamic-urllib-use-detected.dynamic-urllib-use-detected
        with urllib.request.urlopen(req, timeout=10) as response:
            return response.status, dict(response.headers), response.read(262144)
    except urllib.error.HTTPError as error:
        return error.code, dict(error.headers), error.read(262144)


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: api_security_probe.py TARGET REPORT.json", file=sys.stderr)
        return 2
    target = validate_target(sys.argv[1])
    report_path = Path(sys.argv[2])
    findings: list[Finding] = []

    public = ["/v1/auth/health", "/.well-known/jwks.json", "/v1/ai/health"]
    for path in public:
        status, headers, body = request(target, path)
        findings.append(Finding(f"public:{path}", "medium", status == 200, f"HTTP {status}"))
        request_id = headers.get("x-request-id") or headers.get("X-Request-Id")
        findings.append(Finding(f"request-id:{path}", "low", bool(request_id), "present" if request_id else "missing"))
        leaked = any(marker in body.decode("utf-8", "replace").lower() for marker in ("stack trace", "nosuchmethoderror", "databasequeryexception", "/home/"))
        findings.append(Finding(f"error-disclosure:{path}", "high", not leaked, "no obvious internal exception" if not leaked else "internal detail found"))

    protected = [
        "/v1/users/me",
        "/v1/parties/parties",
        "/v1/projects/projects",
        "/v1/ai/capabilities",
    ]
    for path in protected:
        status, _, _ = request(target, path)
        findings.append(Finding(f"missing-auth:{path}", "critical", status in {401, 403}, f"HTTP {status}"))
        status, _, _ = request(target, path, headers={"Authorization": "Bearer invalid.invalid.invalid"})
        findings.append(Finding(f"malformed-jwt:{path}", "critical", status in {401, 403}, f"HTTP {status}"))

    status, headers, _ = request(
        target,
        "/v1/auth/health",
        headers={"Origin": "https://attacker.invalid", "Accept": "application/json"},
    )
    allow_origin = headers.get("access-control-allow-origin") or headers.get("Access-Control-Allow-Origin")
    findings.append(Finding("cors-hostile-origin", "high", allow_origin != "https://attacker.invalid", f"HTTP {status}; allow-origin={allow_origin!r}"))

    status, _, _ = request(target, "/v1/auth/health", method="TRACE")
    findings.append(Finding("trace-method", "medium", status in {404, 405}, f"HTTP {status}"))

    report_path.parent.mkdir(parents=True, exist_ok=True)
    report = {
        "target": target,
        "generatedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "findings": [asdict(item) for item in findings],
    }
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    failed = [item for item in findings if not item.passed]
    for item in findings:
        print(f"{'PASS' if item.passed else 'FAIL'} [{item.severity}] {item.check}: {item.evidence}")
    print(f"report: {report_path}")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
