# NEXUS Backend

The backend is organized as separated services with explicit shared and
infrastructure boundaries.

```text
backend/
├── services/
│   ├── identity/
│   ├── ai_gateway/
│   ├── parties/
│   ├── projects/
│   └── users/
├── shared/
└── infrastructure/
```

## Services

Each service owns its runtime, database, migrations, secrets, and business
logic. A service must not read another service database directly.

Inter-service access must go through an API contract or a dedicated service
client.

## Shared

`shared/` is only for code, contracts, or tooling that is genuinely reused by
more than one service.

Do not put service-specific business logic in `shared/`.

## Infrastructure

`infrastructure/` contains reusable operational building blocks and deployment
assets that are not owned by a single service.

Examples:

- gateway configuration
- common Docker/Vault scripts
- common compose templates
- local orchestration helpers

The current shared Serverpod runtime lives in:

```text
backend/infrastructure/service-runtime/
```

It provides shared Docker images, entrypoints, shell helpers, and Vault Agent
connection config. Each service still keeps its own Compose files, secrets,
Vault templates, database name, ports, and business logic.

## Public API Compatibility

Kong exposes versioned HTTPS/JSON contracts for platform-neutral clients.
Generated Serverpod clients remain an optional optimized transport for Dart and
Flutter applications. Identity, Users, Parties, Projects, and AI capabilities
also expose platform-neutral JSON routes through Kong.

Current gateway prefixes are `/v1/auth`, `/v1/users`, `/v1/parties`,
`/v1/projects`, and `/v1/ai`. Each public REST contract must reuse the same
application layer as its Serverpod RPC endpoint.

OpenAPI contracts currently live at:

- `services/identity/openapi/openapi.yaml`;
- `services/users/openapi/openapi.yaml`;
- `services/parties/openapi/openapi.yaml`;
- `services/projects/projects_server/openapi.yaml`;
- `ia/ai-gateway/openapi.yaml`.
