# Vault Operations

Common Vault operational rules for backend services.

Service-specific secret names, policies, and AppRole names stay in each
service's own Vault docs.

## Production Rules

- Do not run `vault server -dev` in production.
- Do not commit real `secrets/` files.
- Do not share one Vault secret path across services.
- Do not pass AppRole credentials through environment variables.
- Use short-lived `secret_id` values for production deployments.

## Per-Service Secret Paths

Each service must use its own Vault path.

Examples:

```text
identity -> secret/data/nexus/identity
projects -> secret/data/nexus/projects
users    -> secret/data/nexus/users
entities -> secret/data/nexus/entities
legal    -> secret/data/nexus/legal
```

Production paths should be separated from local development paths:

```text
secret/data/nexus/<service>/production
```

## Shared Agent Config

The generic Vault Agent configuration lives in:

```text
backend/infrastructure/service-runtime/vault/
```

Service-specific templates remain in:

```text
backend/services/<service>/<service>_server/docker/vault/templates/
```

This keeps Vault Agent mechanics shared while preserving service ownership of
secret keys.

## Rotation

Rotate in this order:

1. update the real backing service password when rotating DB or Redis;
2. update the service's Vault KV path;
3. wait for Vault Agent to re-render;
4. restart consumers that cannot reload credentials dynamically;
5. verify the service healthcheck and logs.

Updating Vault alone does not change the real PostgreSQL or Redis password.

## Monitoring

Monitor:

- `vault_agent` health;
- rendered file presence under `/vault/secrets`;
- AppRole authentication errors;
- template rendering errors;
- token renewal errors;
- API startup failures due to missing secrets;
- Vault reachability from the deployment network.

