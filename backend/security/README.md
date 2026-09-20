# NEXUS API security chain

This directory contains the defensive security test chain for the NEXUS
backend. It is designed for systems owned by the operator. Dynamic scans are
restricted to loopback targets by default.

## Levels

```text
make security-static       repository, secrets, dependencies, IaC and SAST
make security-probe        safe HTTP checks against local Kong
make security-full         passive ZAP + bounded OpenAPI fuzzing on local Kong
```

Reports are written to `security/reports/` and are ignored by Git. The scripts
use pinned container versions so the host only needs Docker, Python 3 and a
running local NEXUS stack.

### Static checks

- Gitleaks scans the working tree locally and the complete Git history in CI.
- Trivy scans dependencies, secrets and Docker/Compose misconfigurations.
- Semgrep applies community security and secrets rules to authored code.
- the existing Dart analyzer, tests, OpenAPI validation and infrastructure
  validation remain part of the normal backend CI.

Runtime `secrets/` directories are deliberately excluded from filesystem/SAST
reports: those files are already forbidden by service `.gitignore` rules and
must never be copied into a report. Gitleaks still detects any secret that was
actually committed when the CI history scan runs.

### Safe probe

`security-probe` never authenticates and never mutates data. It checks:

- protected routes reject missing and malformed bearer tokens;
- public health/JWKS endpoints remain reachable;
- hostile CORS origins are not reflected;
- request identifiers are returned;
- responses do not disclose stack traces or obvious framework exceptions;
- unexpected HTTP methods are rejected.

Start the backend before running it:

```bash
make up
make security-probe
```

Override the local gateway if needed:

```bash
NEXUS_PENTEST_TARGET=http://127.0.0.1:8000 make security-probe
```

### Full local scan

The full scan adds the ZAP passive baseline and Schemathesis-generated requests
for every OpenAPI contract. These requests can create, update or delete test
data. Run it only against a disposable local stack and database.

```bash
make security-full
```

The scanner refuses non-loopback targets. An authorized remote test requires
the explicit acknowledgement below; never use it on a third-party system:

```bash
NEXUS_PENTEST_TARGET=https://staging.example.test \
NEXUS_PENTEST_ALLOW_REMOTE=I_HAVE_WRITTEN_AUTHORIZATION \
make security-full
```

Authenticated multi-tenant testing needs two disposable identities and tenants.
Use `tests/scripts/kong_gateway_smoke_test.py` to provision the baseline flow,
then add short-lived tokens through `NEXUS_PENTEST_BEARER_TOKEN`. Never commit
tokens or reports.

## Triage

Treat findings as evidence to verify, not automatic proof of a vulnerability.
Prioritize:

1. exposed credentials or authentication bypass;
2. cross-tenant read/write access;
3. remote code execution, injection and SSRF;
4. high/critical dependency and container findings;
5. missing security headers, excessive error detail and availability issues.

Record the affected route, minimal reproduction, impact, fix and regression
test. Rotate any exposed credential immediately, even if it was later removed
from Git history.
