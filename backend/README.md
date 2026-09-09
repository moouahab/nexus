# NEXUS Backend

The backend is organized as separated services with explicit shared and
infrastructure boundaries.

```text
backend/
├── services/
│   ├── identity/
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
