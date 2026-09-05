# Projects Server

`projects_server` is the central registry for NEXUS workspaces.

It owns:

- the `projects` database;
- project lifecycle and metadata;
- links to external resources owned by other services;
- project timeline events;
- project participants and their role in the project.

It does not own authentication, user profiles, organizations, legal records, or
the business logic of linked resources.

## Local Runtime

Use the local setup script from `projects_server/`:

```bash
./docker/script/setup_vault_approle.sh
```

The script creates or reuses local secrets, writes the Projects secret set to
Vault, configures AppRole, starts the Docker stack, and verifies Vault Agent
output.

Runtime ports:

```text
API      127.0.0.1:8280
Insights 127.0.0.1:8281
Web      127.0.0.1:8282
Postgres 127.0.0.1:8290
Redis    127.0.0.1:8291
Vault    127.0.0.1:8300
```

## Shared Runtime

The service uses shared runtime mechanics from:

```text
backend/infrastructure/service-runtime/
```

Shared:

- Serverpod API Dockerfile and entrypoint;
- Postgres image;
- Redis image;
- Vault Agent image;
- Vault Agent connection config;
- common script helpers;
- common Serverpod test runner.

Still specific to `projects`:

- Compose ports, volumes, names, and DB name;
- `docker/script/lib/paths.sh`;
- `docker/script/lib/secrets.sh`;
- `docker/script/lib/vault.sh`;
- `docker/vault/templates/`;
- `secrets/` and `secrets_example/`.

## Secrets

Projects currently needs only the minimal Serverpod runtime secrets:

```text
postgres_password
redis_password
service_secret
vault_dev_root_token
vault_role_id
vault_secret_id
postgres_test_password
redis_test_password
```

SMTP, OAuth, JWT auth, and email verification secrets belong to `identity`.

## Tests

Run from `projects_server/`:

```bash
./docker/script/run_serverpod_tests.sh
```

## Vault Docs

Service-specific Vault procedures live in `docker/vault/docs/`.

Shared Vault operational rules live in
`backend/infrastructure/service-runtime/docs/vault-operations.md`.
