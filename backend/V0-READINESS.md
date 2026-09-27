# NEXUS backend V0 readiness

Status: **READY**  
Validated: 2026-09-27  
Branch: `feat/global-orchestration-elk`  
Validated commit: `4c309b5`  
GitHub Actions: <https://github.com/moouahab/nexus/actions/runs/36305955442>

## Scope of the verdict

The V0 is the secured backend foundation for the multi-tenant NEXUS platform.
It provides Identity, Users, Parties, Projects and AI Gateway behind Kong, with
service-owned PostgreSQL/Redis state, Vault-based runtime secrets and
OpenTelemetry observability.

The release objective is to demonstrate that authenticated users and services
cannot silently cross tenant, project, role, scope or resource boundaries, and
that the backend has reproducible recovery and security evidence.

## Validated release gates

The fail-closed readiness report returned `V0 READY: 7/7 gates passed`:

| Gate | Evidence | Result |
| --- | --- | --- |
| PostgreSQL backup/restore | schema plus per-table row comparison | PASS |
| PostgreSQL temporary loss | isolated disposable dependency proof | PASS |
| Redis temporary loss | isolated disposable dependency proof | PASS |
| API security probes | auth, malformed JWT, CORS, methods, errors, request IDs | PASS |
| Normalized findings | no confirmed High/Critical finding | PASS |
| AI durable startup recovery | orphaned job restored from real PostgreSQL state | PASS |
| Sensitive observability | prompt/token canaries absent from logs and traces | PASS |

Missing evidence is a failure; scanner success cannot replace a required
business or recovery proof.

## Findings closed during final validation

- Identity no longer returns 500 for a missing referenced identity; it emits a
  controlled 404 response.
- Login rejects NUL-containing and oversized values before persistence or
  cryptographic processing.
- Password-reset email length now matches its OpenAPI limit.
- Kong rejects malformed/non-ASCII Bearer headers before Serverpod middleware,
  preventing parser-generated 500 responses.
- ZAP warnings are retained without preventing Schemathesis from running.
- Schemathesis gates on server errors and emits JUnit plus NDJSON evidence for
  every contract.
- The security runner uses its preinstalled Dart SDK, avoiding an unstable
  1.33 GB Flutter download during the release job.

## Evidence policy

Evidence is written under `security/reports/` and uploaded by CI. The normalized
finding schema contains severity, confidence, service, endpoint, category, CWE,
OWASP API category, evidence, reproduction, recommendation, tool and run ID.

Evidence priority is:

```text
reproducible business test
> deterministic probe
> reproducible DAST
> precise SAST path
> generic scanner pattern
```

ZAP baseline warnings and OpenAPI conformance warnings remain triage inputs.
Only reviewed, confirmed High/Critical findings block the normalized gate;
Schemathesis 5xx failures block the dynamic scan directly.

## Runtime and CI contract

- pull request: `security-static`;
- push to `main` or `staging`: `security-probe`;
- weekly schedule or manual dispatch: `security-full`;
- dynamic jobs: ephemeral self-hosted runner labelled
  `nexus-disposable-security`;
- target: loopback or an explicitly reviewed private scope manifest;
- Internet and destructive testing: denied by default.

The runner must provide Docker, Python 3 and Dart, start a disposable stack with
Kong on `127.0.0.1:8000`, and reset test data between campaigns.

## Meaning of READY

`READY` authorizes the transition from the V0 secured foundation to V1 product
development. It is not approval to expose the local stack directly to the
Internet.

Before production exposure, NEXUS still requires:

- production TLS and certificate lifecycle management;
- centralized/high-availability Vault and automated secret rotation;
- distributed rate limiting rather than node-local counters;
- production alerting, retention and centralized observability operations;
- off-host encrypted backups with scheduled restore exercises;
- dedicated maintained security runners;
- sustained load/capacity testing;
- closure or explicit acceptance of remaining ZAP/OpenAPI warnings;
- an independent security review before public launch.

## Reproduce the verdict

With the disposable stack running and all required evidence generated:

```bash
python3 security/scripts/normalize_findings.py --gate
python3 security/scripts/v0_readiness.py --gate
```

The second command must print `V0 READY: 7/7 gates passed` and exit successfully.
