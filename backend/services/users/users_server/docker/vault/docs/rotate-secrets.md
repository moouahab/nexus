# Rotate Vault Secrets

This procedure covers rotation for:

- AppRole `secret_id`
- Vault Agent tokens
- application secrets stored in Vault
- real PostgreSQL and Redis passwords

Run production Vault commands from an operator machine that has access to the
production Vault server.

## 1. AppRole `secret_id` Rotation

The `role_id` is stable. The `secret_id` should be short-lived and rotated for
each deployment.

Recommended AppRole settings:

```bash
vault write auth/approle/role/users-production \
  policies=users-production-read \
  token_ttl=15m \
  token_max_ttl=1h \
  secret_id_ttl=24h \
  secret_id_num_uses=1
```

Generate a new `secret_id`:

```bash
vault write -field=secret_id -f \
  auth/approle/role/users-production/secret-id
```

Deployment flow:

1. Generate a fresh `secret_id`.
2. Store it in the deployment platform secret store.
3. Deploy or restart `vault_agent`.
4. Verify Vault Agent becomes healthy.
5. Verify rendered files exist.

## 2. Vault Agent Token Rotation

Vault Agent receives a Vault token after AppRole authentication. The application
does not manage that token manually.

Vault Agent renews its token while it is running. Rotation happens by restarting
Vault Agent with a valid AppRole `role_id` and `secret_id`.

```bash
docker compose -f docker/compose/prod.yaml up --detach --force-recreate vault_agent
```

Verify:

```bash
docker compose -f docker/compose/prod.yaml exec vault_agent ls -l /vault/token/agent-token
docker compose -f docker/compose/prod.yaml exec vault_agent ls -l /vault/secrets
```

## 3. Application Secret Rotation

Application secrets rendered into `serverpod-passwords.yaml` come from:

```text
secret/data/nexus/users/production
```

Expected keys:

```text
postgres_password
redis_password
service_secret
```

Rotate application-only secrets by updating Vault:

```bash
vault kv patch secret/nexus/users/production \
  service_secret='<new-service-secret>'
```

Restart the API if it does not reload the rendered file dynamically:

```bash
docker compose -f docker/compose/prod.yaml up --detach --force-recreate api
```

## 4. PostgreSQL Password Rotation

Changing `postgres_password` in Vault does not change the real PostgreSQL
password.

Rotate in this order:

1. Confirm an operator database account still works.
2. Change the real PostgreSQL password.
3. Update Vault.
4. Wait for Vault Agent to re-render.
5. Restart the API.
6. Verify API connectivity.

Example SQL:

```sql
ALTER USER postgres WITH PASSWORD '<new-production-postgres-password>';
```

Update Vault:

```bash
vault kv patch secret/nexus/users/production \
  postgres_password='<new-production-postgres-password>'
```

Restart API:

```bash
docker compose -f docker/compose/prod.yaml up --detach --force-recreate api
```

## 5. Redis Password Rotation

Changing `redis_password` in Vault does not change the real Redis password.

Rotate in this order:

1. Change the real Redis password.
2. Update Vault.
3. Wait for Vault Agent to re-render.
4. Restart consumers.
5. Verify connectivity.

For managed Redis, rotate through the provider. For self-managed Redis, update
its auth configuration and reload or restart Redis according to its operational
procedure.

Update Vault:

```bash
vault kv patch secret/nexus/users/production \
  redis_password='<new-production-redis-password>'
```

Restart API:

```bash
docker compose -f docker/compose/prod.yaml up --detach --force-recreate api
```

## 6. Verification Checklist

After any rotation:

```bash
docker compose -f docker/compose/prod.yaml ps
docker compose -f docker/compose/prod.yaml logs --no-color --tail=120 vault_agent api
docker compose -f docker/compose/prod.yaml exec vault_agent ls -l /vault/secrets
```

Expected:

- `vault_agent` is healthy
- `api` is healthy
- `serverpod-passwords.yaml` exists and is not empty
- database/cache credentials match the real services
- no real secret is committed to Git

## 7. Rollback

Keep previous secret values available in the secure operator context until the
rotation is verified.

If the API cannot connect after rotation:

1. Restore the previous real DB or Redis password.
2. Restore the previous Vault value.
3. Restart Vault Agent or wait for re-render.
4. Restart API.
5. Verify health.
