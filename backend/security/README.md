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

NEXUS-specific rules live in `security/semgrep/nexus.yml`. They focus on
outbound requests without timeouts, missing interservice authorization, SSRF
candidates, sensitive logging and raw exception disclosure. A match is a
review lead, not automatically a confirmed vulnerability.

The local rules also flag service authentication calls which omit an explicit
`requiredScopes` boundary. Route/RPC authorization parity, project read versus
management authorization, and REST/OpenAPI inventory parity are deliberately
enforced by deterministic architecture tests instead of broad Semgrep
patterns: those properties are split across route adapters, endpoint methods
and application services, so a single-file pattern would create misleading
false positives and false negatives. Semgrep's Dart parser can also report
partial parsing for newer language syntax; its JSON `errors` array must be
retained with the findings as coverage evidence.

Runtime `secrets/` directories are deliberately excluded from filesystem/SAST
reports: those files are already forbidden by service `.gitignore` rules and
must never be copied into a report. Gitleaks still detects any secret that was
actually committed when the CI history scan runs. CI sets
`NEXUS_GITLEAKS_HISTORY=true`; local scans default to the working tree.

### Unified findings and CI gate

`security/scripts/normalize_findings.py` consumes Semgrep JSON, SARIF and native
JSON. It produces the deduplicated `security/reports/findings.json` with the
common NEXUS evidence fields. Scanner results are unconfirmed by default.
After deterministic reproduction, add the fingerprint and reviewed decision
to `security/policy/finding-triage.json`. The CI gate fails on confirmed High
or Critical findings:

```bash
python3 security/scripts/normalize_findings.py --gate
```

### Backup/restore and resilience

The backup proof accepts only a `*_postgres_test-*` container and a `*_test`
database. It restores into a randomly named temporary database, compares the
table inventory and exact per-table row counts, emits JSON evidence, and deletes only its temporary objects. The source
database is never dropped or rewritten.

```bash
NEXUS_DISPOSABLE_DATABASE=I_UNDERSTAND_THIS_IS_DISPOSABLE \
  security/scripts/backup_restore_test.sh \
  projects_server-postgres_test-1 projects_test
```

The initial resilience check only restarts a test API and waits for a
scope-guarded local health URL. It is a dry run unless both execution and the
disposable-stack acknowledgement are provided:

```bash
security/scripts/resilience_test.sh projects_server-api_test-1 \
  http://127.0.0.1:8000/v1/projects/health
```

Temporary PostgreSQL and Redis loss uses a separate guard. It accepts only
Compose services named `postgres_test` or `redis_test`, is a dry run by
default, refuses redirects and out-of-scope probes, pins curl to the DNS
addresses validated by the scope guard (preventing rebinding/TOCTOU), and
writes JSON evidence:

```bash
security/scripts/dependency_resilience_test.sh postgres \
  nexus-security-postgres_test-1 http://127.0.0.1:8000/probe/projects

NEXUS_RESILIENCE_EXECUTE=true \
NEXUS_DISPOSABLE_STACK=I_UNDERSTAND_THIS_IS_DISPOSABLE \
NEXUS_DISPOSABLE_PROJECT=nexus-security \
security/scripts/dependency_resilience_test.sh redis \
  nexus-security-redis_test-1 http://127.0.0.1:8000/probe/session
```

Execution verifies the exact Docker Compose project and service labels before
pausing anything. A trap restores the dependency on interruption. The URL must
be a dependency-backed probe, not a shallow process health endpoint.
Destructive chaos remains excluded.
The backup proof compares schema table inventory and exact row counts; it does
not yet compute a canonical content checksum for every PostgreSQL data type.

The weekly/manual workflow runs backup/restore and temporary PostgreSQL/Redis
loss against an isolated Compose project. The same proof can be run locally
only with an explicit disposable-stack acknowledgement:

```bash
NEXUS_DISPOSABLE_STACK=I_UNDERSTAND_THIS_IS_DISPOSABLE \
  make security-operational
```

### V0 release verdict

`make security-v0-readiness` is fail-closed. It emits
`security/reports/v0-readiness.json` and refuses release until every required
artifact is present and green. In particular, scanner success cannot replace
the business proofs for AI job recovery after restart and absence of
prompt/token canaries from logs and traces. Both proofs run in the weekly and
manual full-security workflow; a missing or failed artifact blocks the job.

The final V0 validation passed **7/7 gates** on commit `4c309b5`:

<https://github.com/moouahab/nexus/actions/runs/36305955442>

The seven release gates prove:

1. PostgreSQL backup and restore preserve table and row inventories;
2. temporary PostgreSQL loss is recovered;
3. temporary Redis loss is recovered;
4. deterministic API security probes pass;
5. no confirmed High or Critical normalized finding remains;
6. an orphaned AI job is recovered from real PostgreSQL state at startup;
7. prompt and token canaries do not appear in exported logs or traces.

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

ZAP exit code 2 means that the passive baseline produced warnings. Those
warnings remain in the JSON/HTML evidence and do not stop the rest of the scan;
ZAP confirmed failures and incomplete scans still fail immediately.

Schemathesis runs examples, coverage and fuzzing at a bounded 300 requests per
minute. Its CI gate is `not_a_server_error`: every generated request must avoid
a 5xx response. Contract-conformance differences remain visible as warnings
for OpenAPI triage instead of being confused with confirmed security defects.
Each contract produces JUnit XML and NDJSON evidence in `security/reports/`.

```bash
NEXUS_DISPOSABLE_STACK=I_UNDERSTAND_THIS_IS_DISPOSABLE make security-full
```

The scanner refuses targets outside its scope manifest. Authorized staging
requires a reviewed manifest containing the host and CIDRs; a textual
acknowledgement cannot bypass the guard:

```bash
NEXUS_PENTEST_TARGET=https://staging.example.test \
NEXUS_PENTEST_SCOPE=security/policy/authorized-staging.scope.yaml \
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

## CI execution levels

The security workflow has one level per trigger: pull requests run
`security-static`, pushes to `main` or `staging` run `security-probe`, and the
weekly schedule or a manual dispatch runs `security-full`. Evidence is uploaded
from `security/reports/` with a level-specific artifact name.

Dynamic jobs require a self-hosted runner labelled
`nexus-disposable-security`. Before accepting jobs, that runner must start a
disposable NEXUS stack whose Kong gateway listens only on
`http://127.0.0.1:8000`, reset its test data between runs, and stop it after the
job. The workflow deliberately does not fall back to a remote host: both probe
and full scans use `local.scope.yaml` and fail closed when the local gateway is
absent. The full level additionally requires the explicit disposable-stack
acknowledgement.

The disposable runner contract also requires a working `dart` executable on
`PATH`. The workflow verifies the preinstalled SDK instead of downloading the
full Flutter archive for every security run. An ephemeral runner is preferred:
GitHub removes its credentials and registration after the single job.
