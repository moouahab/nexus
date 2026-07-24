# Production Vault Setup

This procedure explains how to move from the local development Vault setup to a
production-oriented Vault Agent setup.

The production rule is simple:

```text
Do not run `vault server -dev` in production.
```

In production, Vault Agent should connect to an existing, secured Vault server.

## Target Architecture

```text
Production Vault server
  external to this Compose stack
  persistent storage
  TLS enabled
  audit logs enabled
  managed unseal process

Vault Agent
  runs with the identity service stack
  authenticates using AppRole or platform identity
  renders secret files

Identity services
  api
  postgres or external database
  redis or external cache
```

## 1. Prepare A Real Vault Server

Use one of these options:

- HCP Vault
- Vault on Kubernetes
- Vault on a dedicated VM
- Vault managed by your infrastructure platform

Minimum production requirements:

- TLS enabled
- persistent storage backend
- backup strategy
- audit logging enabled
- restricted network access
- no root token used by applications
- no `server -dev`

## 2. Choose The Production Secret Path

The current development templates read:

```text
secret/data/nexus/identity
```

For production, use a clearly separated path, for example:

```text
secret/data/nexus/identity/production
```

Expected keys:

```text
postgres_password
redis_password
service_secret
email_secret_hash_pepper
jwt_hmac_sha512_private_key
jwt_refresh_token_hash_pepper
```

Example:

```bash
vault kv put secret/nexus/identity/production \
  postgres_password='<production-postgres-password>' \
  redis_password='<production-redis-password>' \
  service_secret='<production-serverpod-service-secret>' \
  email_secret_hash_pepper='<production-email-secret-hash-pepper>' \
  jwt_hmac_sha512_private_key='<production-jwt-hmac-sha512-private-key>' \
  jwt_refresh_token_hash_pepper='<production-jwt-refresh-token-hash-pepper>'
```

## 3. Create A Production Policy

Create `identity-production-read.hcl`:

```hcl
path "secret/data/nexus/identity/production" {
  capabilities = ["read"]
}
```

Apply it:

```bash
vault policy write identity-production-read identity-production-read.hcl
```

This policy should only allow the identity service to read the exact secret path
it needs.

## 4. Enable Or Reuse AppRole

If AppRole is not enabled:

```bash
vault auth enable approle
```

Create a production AppRole:

```bash
vault write auth/approle/role/identity-production \
  policies=identity-production-read \
  token_ttl=15m \
  token_max_ttl=1h \
  secret_id_ttl=24h \
  secret_id_num_uses=1
```

Generate credentials:

```bash
vault read -field=role_id \
  auth/approle/role/identity-production/role-id

vault write -field=secret_id -f \
  auth/approle/role/identity-production/secret-id
```

Store these values in your production secret delivery mechanism. Do not commit
them.

## 5. Create A Production Vault Agent Config

The production config is generated from:

```text
docker/vault/agent-production.hcl
docker/vault/production-vault-address
docker/vault/tls/production-ca.crt
```

Set the real Vault address in:

```text
docker/vault/production-vault-address
```

Example file content:

```text
https://vault.production.internal:8200
```

Put the production Vault CA certificate in:

```text
docker/vault/tls/production-ca.crt
```

The production agent config uses TLS CA verification:

```hcl
vault {
  address = "__VAULT_ADDRESS__"
  ca_cert = "/vault/tls/ca.crt"
}
```

The template paths should read the production secret path:

```hcl
template {
  source      = "/vault/templates/postgres_password.ctmpl"
  destination = "/vault/secrets/postgres_password"
  perms       = "0440"
}

template {
  source      = "/vault/templates/redis_password.ctmpl"
  destination = "/vault/secrets/redis_password"
  perms       = "0440"
}
```

And the templates should use:

```text
secret/data/nexus/identity/production
```

Production also renders a complete Serverpod passwords file:

```text
/vault/secrets/serverpod-passwords.yaml
```

The API uses this rendered file directly, so production does not mount
`config/passwords.yaml` as a secret template.

## 6. Split Dev And Production Compose Files

The current local stack includes a development Vault service:

```yaml
vault:
  image: hashicorp/vault:1.17
```

Production should not include this service.

Recommended structure:

```text
docker-compose.yaml
docker/compose/dev.yaml
docker/compose/test.yaml
docker/compose/vault-agent.yaml
docker/compose/prod.yaml
```

In production:

- remove the `vault` service
- keep `vault_agent`
- mount production Vault Agent config
- mount production AppRole credentials through your orchestrator secret system
- keep rendered secrets mounted read-only into consumers

This repository provides a production Compose starting point:

```text
docker/compose/prod.yaml
```

It intentionally does not include:

- the local `vault` dev server
- local `postgres`
- local `redis`

Validate it with:

```bash
docker compose -f docker/compose/prod.yaml config
```

Before using it, update:

```text
docker/vault/production-vault-address
docker/vault/tls/production-ca.crt
```

The production Compose validates with:

```bash
docker compose -f docker/compose/prod.yaml config
```

## 7. Production Secret Delivery

Do not place production AppRole credentials in local files copied by hand.

Use the platform secret mechanism:

- Docker Swarm secrets
- Kubernetes Secrets or external secrets operator
- CI/CD secret store
- cloud secret manager used only to bootstrap Vault Agent

The files expected by Vault Agent are:

```text
/run/secrets/role_id
/run/secrets/secret_id
```

For local validation of the production Compose shape, example files exist under:

```text
secrets_example/production/
```

Real production values must be stored in the deployment platform secret store,
not committed to Git.

## 8. Rotate Secret IDs

With:

```text
secret_id_num_uses=1
secret_id_ttl=24h
```

each deployment should receive a fresh `secret_id`.

Rotation flow:

```bash
vault write -field=secret_id -f \
  auth/approle/role/identity-production/secret-id
```

Then update the production secret store and redeploy Vault Agent.

## 9. Rotate Runtime Secrets

When rotating `postgres_password` or `redis_password`:

1. update the real backing service password,
2. update Vault KV,
3. let Vault Agent re-render files,
4. restart the dependent service if it cannot reload credentials dynamically.

Postgres and Redis usually require careful rotation planning. Do not only update
Vault if the actual database/cache password has not changed.

## 10. Validation Checklist

Before production traffic:

```bash
vault policy read identity-production-read
vault read auth/approle/role/identity-production
```

On the deployed host/container:

```bash
ls -l /vault/secrets
```

Expected:

```text
postgres_password
redis_password
serverpod-passwords.yaml
```

Service checks:

```bash
docker compose ps
docker compose logs --no-color --tail=120 vault_agent api
```

Expected:

- Vault Agent stays running
- rendered secret files exist
- API starts successfully
- `config/passwords.yaml` is not mounted in production
- no root token is present in the application stack
- no `vault server -dev` process exists

## 11. Production Hardening Notes

Recommended follow-up work:

- avoid long-lived AppRole `secret_id`
- enable Vault audit devices
- use separate Vault policies per service
- separate dev, staging, and production secret paths
- do not share Vault root token with application deployment
- avoid running Postgres and Redis in the same Compose stack for production when
  managed services are available
- add monitoring for Vault Agent template rendering failures

Operational procedures:

- `docker/vault/docs/rotate-secrets.md`
- `docker/vault/docs/production-monitoring.md`
- `docker/vault/docs/inject-approle-secrets.md`
