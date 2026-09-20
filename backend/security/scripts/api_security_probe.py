#!/usr/bin/env python3
"""Non-destructive security assertions for the Kong API boundary."""

from __future__ import annotations

import json
import sys
import time
import urllib.error
import urllib.parse
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


@dataclass(frozen=True)
class ProtectedOperation:
    service: str
    method: str
    path: str


# Keep this inventory aligned with the operations which inherit or declare a
# non-empty `security` section in the five OpenAPI contracts. Testing the HTTP
# method as well as the path matters: several resources expose both a read and
# a write operation, and either one can accidentally lose its auth middleware.
PROTECTED_OPERATIONS = (
    ProtectedOperation("identity", "POST", "/v1/auth/logout"),
    ProtectedOperation("identity", "GET", "/v1/auth/me"),
    ProtectedOperation("identity", "POST", "/v1/auth/me"),
    ProtectedOperation("identity", "POST", "/v1/auth/password/change"),
    ProtectedOperation("identity", "POST", "/v1/auth/email/change"),
    ProtectedOperation("users", "GET", "/v1/users/me"),
    ProtectedOperation("users", "PUT", "/v1/users/me"),
    ProtectedOperation("users", "POST", "/v1/users/profiles"),
    ProtectedOperation("users", "GET", "/v1/users/profiles/{profileId}"),
    ProtectedOperation("users", "GET", "/v1/users/profiles/by-identity/{identityId}"),
    ProtectedOperation("users", "PUT", "/v1/users/profiles/{profileId}/primary-party"),
    ProtectedOperation("parties", "GET", "/v1/parties/parties"),
    ProtectedOperation("parties", "POST", "/v1/parties/parties"),
    ProtectedOperation("parties", "GET", "/v1/parties/parties/{partyId}"),
    ProtectedOperation("parties", "POST", "/v1/parties/parties/with-owner"),
    ProtectedOperation("parties", "POST", "/v1/parties/parties/{partyId}/memberships"),
    ProtectedOperation("parties", "GET", "/v1/parties/memberships?userProfileId={userProfileId}"),
    ProtectedOperation("projects", "POST", "/v1/projects/projects"),
    ProtectedOperation("projects", "GET", "/v1/projects/tenants/{tenantId}/projects"),
    ProtectedOperation("projects", "GET", "/v1/projects/projects/{projectId}"),
    ProtectedOperation("projects", "PATCH", "/v1/projects/projects/{projectId}"),
    ProtectedOperation("projects", "POST", "/v1/projects/projects/{projectId}/status"),
    ProtectedOperation("projects", "GET", "/v1/projects/projects/{projectId}/ai-access?tenantPartyId={tenantPartyId}"),
    ProtectedOperation("projects", "POST", "/v1/projects/projects/{projectId}/archive"),
    ProtectedOperation("projects", "POST", "/v1/projects/projects/{projectId}/restore"),
    ProtectedOperation("projects", "GET", "/v1/projects/projects/{projectId}/participants"),
    ProtectedOperation("projects", "POST", "/v1/projects/projects/{projectId}/participants"),
    ProtectedOperation("projects", "GET", "/v1/projects/projects/{projectId}/links"),
    ProtectedOperation("projects", "POST", "/v1/projects/projects/{projectId}/links"),
    ProtectedOperation("projects", "GET", "/v1/projects/projects/{projectId}/events"),
    ProtectedOperation("ai", "GET", "/v1/ai/capabilities"),
    ProtectedOperation("ai", "POST", "/v1/ai/context/preview"),
    ProtectedOperation("ai", "POST", "/v1/ai/runs"),
    ProtectedOperation("ai", "GET", "/v1/ai/runs/{runId}"),
    ProtectedOperation("ai", "POST", "/v1/ai/runs/{runId}/cancel"),
)

_PLACEHOLDER_VALUE = "00000000-0000-4000-8000-000000000001"


def concrete_path(path: str) -> str:
    """Replace OpenAPI path/query placeholders with a syntactically valid UUID."""
    while "{" in path:
        start = path.index("{")
        end = path.index("}", start)
        path = path[:start] + urllib.parse.quote(_PLACEHOLDER_VALUE) + path[end + 1 :]
    return path


def request(target: str, path: str, method: str = "GET", headers=None):
    request_headers = {"Accept": "application/json"}
    request_headers.update(headers or {})
    data = None
    if method in {"POST", "PUT", "PATCH"}:
        request_headers["Content-Type"] = "application/json"
        data = b"{}"
    req = urllib.request.Request(
        target + path,
        method=method,
        headers=request_headers,
        data=data,
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

    for operation in PROTECTED_OPERATIONS:
        path = concrete_path(operation.path)
        check = f"{operation.service}:{operation.method}:{operation.path}"
        status, _, _ = request(target, path, method=operation.method)
        findings.append(Finding(f"missing-auth:{check}", "critical", status in {401, 403}, f"HTTP {status}"))
        status, _, _ = request(
            target,
            path,
            method=operation.method,
            headers={"Authorization": "Bearer invalid.invalid.invalid"},
        )
        findings.append(Finding(f"malformed-jwt:{check}", "critical", status in {401, 403}, f"HTTP {status}"))

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
