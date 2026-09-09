# Backend Infrastructure

This directory contains infrastructure assets shared across backend services.

Current areas:

```text
infrastructure/
├── kong/
└── service-runtime/
```

## Kong

`kong/` is the cross-platform API gateway entrypoint. It currently routes:

- `/v1/auth`
- `/v1/users`
- `/v1/parties`
- `/v1/projects`
- `/.well-known`

## Service Runtime

`service-runtime/` is the home for reusable Docker, Vault, and local runtime
scripts used by Serverpod services.

Each service should still keep its own:

- database name
- database volume
- ports
- Vault secret path
- Vault policy
- AppRole name
- declared secret list

The common runtime should provide mechanics, not service ownership.

Detailed convention:

```text
service-runtime/docs/serverpod-service-runtime.md
```
