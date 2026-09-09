# Serverpod Service Runtime

This runtime contains the Docker and script mechanics shared by backend
Serverpod services.

It is used by:

- `services/identity/identity_server`
- `services/parties/parties_server`
- `services/projects/projects_server`
- `services/users/users_server`

## Shared Docker Images

```text
backend/infrastructure/service-runtime/docker/
├── postgres/
├── redis/
├── serverpod-api/
└── vault-agent/
```

The images are intentionally generic:

- `postgres/` reads `POSTGRES_USER` and `POSTGRES_DB` from the service config.
- `redis/` reads its password from Docker secrets or Vault Agent output.
- `vault-agent/` authenticates with AppRole and renders secret files.
- `serverpod-api/` compiles and runs a Serverpod service using build args.

## Serverpod API Build Args

Each service keeps its own Compose file and passes its package names to the
common API Dockerfile:

```yaml
build:
  context: ../../..
  dockerfile: ../../infrastructure/service-runtime/docker/serverpod-api/Dockerfile
  additional_contexts:
    service_runtime: ../../../../../infrastructure/service-runtime/docker/serverpod-api
  args:
    SERVER_PACKAGE: projects_server
    CLIENT_PACKAGE: projects_client
    RUNTIME_USER: projects
    ENTRYPOINT_TARGET: /usr/local/bin/serverpod-api-entrypoint
```

The main build context stays scoped to the service workspace. The additional
context exposes only the shared API entrypoint.

## Shared Scripts

```text
backend/infrastructure/service-runtime/script/
├── lib/common.sh
├── lib/docker.sh
└── serverpod/run_tests.sh
```

Service scripts remain in each service and source the shared helpers.

The shared test runner supports optional auth test secrets:

```bash
SERVERPOD_TEST_AUTH_PASSWORDS=true
```

`identity` enables this flag. `projects` does not, because authentication
belongs to `identity`.

## Shared Vault Agent Config

```text
backend/infrastructure/service-runtime/vault/
├── agent.hcl
├── agent-production.hcl
├── dev-listen-address
├── production-vault-address
└── tls/production-ca.crt
```

These files define the generic Vault Agent behavior. Service-specific Vault
templates remain inside each service because they select the service secret
path and rendered Serverpod password keys.

## What Must Stay In Each Service

Each service keeps:

- Docker Compose files with its ports, volumes, names, and database name;
- `docker/script/lib/paths.sh`;
- `docker/script/lib/secrets.sh`;
- `docker/script/lib/vault.sh`;
- `docker/vault/templates/`;
- `secrets/` and `secrets_example/`;
- Serverpod models, endpoints, migrations, and tests.

Do not move service secrets or service business rules into this runtime.
