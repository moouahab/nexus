# NEXUS AI Gateway

This directory owns the cross-platform contract for the implemented AI Gateway.
The executable Serverpod service and Ollama integration live under
`../../services/ai_gateway`.

## Purpose

AI Gateway is the single backend boundary for AI capabilities in NEXUS:

- validate caller authentication and service scopes;
- validate project authorization through the Projects service contract;
- resolve request correlation IDs;
- route requests through bounded reasoning, verification, and validation;
- audit AI runs without logging raw prompts, secrets, documents, or evidence.

Business services must not call AI providers directly; they call AI Gateway.

## Initial Public Contract

The initial HTTP contract is defined in `openapi.yaml`.

Gateway paths:

```text
GET  /v1/ai/health
GET  /v1/ai/capabilities
POST /v1/ai/context/preview
POST /v1/ai/runs
GET  /v1/ai/runs/{runId}
POST /v1/ai/runs/{runId}/cancel
```

Kong publishes these routes while the provider remains internal.

## Authentication

Service-to-service calls must use NEXUS service tokens validated by
`shared/nexus_auth`:

```text
typ = service
sub = service:<caller>
aud = ai-gateway
scope = ai.context.preview ai.run.create ai.run.read ai.run.cancel
```

User-facing calls must use Identity user access tokens and must be authorized
against Projects before any project context is resolved.

## Authorization Boundary

AI Gateway must not read another service database directly.

Project authorization and evidence use the Projects REST contract:

```text
Projects.canReadProject(identityId, projectId, tenantPartyId)
Projects.canUseAiForProject(identityId, projectId, tenantPartyId)
```

Unavailable authorization or evidence sources fail closed.

## Observability

Every request must carry or create an `x-request-id`.

Logs and audit events may include:

- request ID;
- caller service name;
- actor identity ID;
- project ID;
- AI run ID;
- capability;
- status and failure code.

Logs and audit events must not include:

- raw prompts;
- access tokens;
- provider API keys;
- full documents;
- full evidence payloads;
- secrets or credentials.
# AI Gateway public contract

The executable Serverpod service now lives in
[`../../services/ai_gateway`](../../services/ai_gateway). This directory owns
the provider-neutral public REST contract and deployment manifest.

The implementation is intentionally fail-closed: creating a run is denied
unless Projects positively verifies project and tenant access. Ollama can be
configured as the local provider; it never decides evidence confidence itself.
