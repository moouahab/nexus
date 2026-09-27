# Backend Infrastructure

This directory contains infrastructure assets shared across backend services.

Current areas:

```text
infrastructure/
├── kong/
└── service-runtime/
```

## Global local orchestration

The root `Makefile` is the global control plane for the local stack while each
service remains an independent Compose project and an independent set of
containers:

```bash
make up          # first start / Vault initialization
make stack-up    # start all existing projects
make stack-ps    # unified status
make stack-logs  # unified log stream
make stack-down  # stop all projects and Kong
```

The existing Compose project names remain stable, so adopting the global
commands does not create a second copy of already-running containers. The
root orchestration manages them as one platform without nesting Docker daemons
or merging service lifecycles.

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
