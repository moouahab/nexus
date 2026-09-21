# Nexus AI Gateway

This directory contains the Serverpod 3.4.11 implementation of the AI
orchestration boundary. Ollama is the first local provider integration.

## Current behavior

- `health` is public and reports the process contract.
- protected operations require a Nexus user access token or a service token
  for audience `ai-gateway` with the matching `ai.run.*` scope. Run creation is
  temporarily user-only: service creation fails closed until a delegated
  service grant flow is implemented.
- `POST /runs` authorizes and validates the request, persists a `queued` run,
  and returns immediately. Serverpod FutureCalls execute it asynchronously.
- the internal `ai_run_job` table temporarily persists the bounded input and
  a short-lived Projects authorization grant needed by a restart-safe worker;
  the inbound caller bearer is never persisted. The job is server-only, is never
  returned by an API, and its sensitive fields are overwritten after success,
  failure, or cancellation. Database volume encryption and restricted DB roles
  are required because this transient payload is not application-encrypted.
- project authorization is delegated to Projects using the caller bearer only
  for the synchronous authorization check. Projects returns a signed grant;
  Identity verifies it before issuing an exact project-bound worker token.
- authorized runs execute a bounded Planner → Evidence → Draft → Verify →
  Critic → Finalizer cycle. Intermediate stages are exposed in `AiRun`.
- verification scoring is deterministic and evidence-backed; the LLM cannot
  mark its own claims verified. No evidence means no confirmed conclusion.
- claims, normalized evidence references, and their relations are persisted
  separately from prompts. High-risk conclusions require human approval.
- prompts are never stored in the public/audit `ai_run` model. They exist only
  in the transient job payload until that job reaches a terminal state; the
  controlled output and provider/model metadata remain on the run.
- `Idempotency-Key` is optional, trimmed, limited to 128 characters, and scoped
  by tenant plus authenticated identity/service. Concurrent duplicates resolve
  to the same run through a database unique constraint.
- job claiming locks the job and run in one transaction; duplicate deliveries
  are no-ops. Worker concurrency is bounded by `futureCall.concurrencyLimit`
  (1 in tests, 2 in development/staging, 4 in production).

The generated Serverpod RPC methods remain available for Dart clients. The
web server also exposes the platform-neutral JSON API described by
`../../ia/ai-gateway/openapi.yaml`:

- `GET /health` (public)
- `GET /capabilities`
- `POST /context/preview`
- `POST /runs`
- `GET /runs/{runId}`
- `POST /runs/{runId}/cancel`

All protected routes accept `Authorization: Bearer <JWT>`. User access tokens
and service tokens (audience `ai-gateway`, matching `ai.run.*` scope) use the
same application boundary as RPC calls. Errors use the stable JSON shape
`{"error":{"code":"...","message":"..."}}`; internal exception details are
not returned. Request bodies are limited to 1 MiB. Kong can publish these
upstream paths below the contract base URL `/v1/ai`.

## Development

```sh
cd services/ai_gateway
dart pub get
cd ai_gateway_server
serverpod generate
serverpod create-migration
cd ..
dart analyze
dart test
```

Tests requiring persistence need a PostgreSQL test database on port `9590`.
They are skipped explicitly by the default suite so that unit tests do not
terminate when the database is absent. Run them in CI or locally with the test
stack started and the opt-in environment variable enabled:

```sh
AI_GATEWAY_RUN_DATABASE_TESTS=true dart test \
  ai_gateway_server/test/ai/reasoning_persistence_database_test.dart
```

Pure authorization boundary tests do not require Docker.

## Ollama on Windows / WSL2

The development Compose stack enables Ollama with `llama3.2:3b` by default.
This model completed the local connectivity test in about 27 seconds;
`qwen3.5:9b` is available as an opt-in model but exceeded the 120-second test
timeout on the current machine.
`make ai-gateway-up` resolves the current Windows host gateway from WSL and
passes it as `OLLAMA_BASE_URL`; this avoids persisting a WSL address that can
change after a restart.

Equivalent manual startup:

```sh
cd services/ai_gateway/ai_gateway_server
OLLAMA_BASE_URL="http://$(ip route show default | awk '{print $3; exit}'):11434" \
  docker compose up -d
```

Configuration variables:

```text
AI_PROVIDER=ollama
OLLAMA_BASE_URL=http://<windows-wsl-gateway>:11434
OLLAMA_MODEL=llama3.2:3b
OLLAMA_TIMEOUT_SECONDS=120
OLLAMA_MAX_TOKENS=512
PROJECTS_BASE_URL=http://projects-api:8082
PROJECTS_TIMEOUT_SECONDS=10
PROJECTS_EVIDENCE_MAX_EVENTS=25
PROJECTS_EVIDENCE_MAX_BYTES=1048576
```

The durable queue requires PostgreSQL and Serverpod future-call execution to
remain enabled. A queued call survives process restarts. Operators should alert
on runs that remain `queued` or `running` beyond the provider timeout. Serverpod
3.4.11 scans due FutureCall rows independently of their recorded `serverId`, so
a deployment using a new server id still consumes old work. Startup recovery
also recreates a missing call and requeues a processing lease older than 30
minutes; atomic job claiming keeps a duplicate recovery delivery harmless.

Ollama is never routed through Kong. Project authorization is evaluated before
any prompt is sent to the provider, and prompts are not stored in `ai_run`.
Only the context categories requested by the planner are fetched. The current
tool registry reads project metadata and recent project events; Work, GitHub,
Cyber, Documents, and other services can be added as isolated `NexusTool`
adapters without changing the orchestrator.
