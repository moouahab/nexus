# Generate Vault AppRole Secrets

This procedure creates the local Vault AppRole files required by Vault Agent:

- `secrets/vault_role_id`
- `secrets/vault_secret_id`

Run every command from `identity_server/`.

## 1. Create Local Secret Files

Start from the example directory:

```bash
cp -r secrets_example secrets
```

Set a local development root token for Vault:

```bash
printf '%s' 'change-this-dev-root-token' > secrets/vault_dev_root_token
```

## 2. Start Local Vault

```bash
docker compose up --build --detach vault
```

## 3. Login To Vault

```bash
docker compose exec vault vault login -address=http://127.0.0.1:8200 "$(cat secrets/vault_dev_root_token)"
```

## 4. Store Runtime Secrets

Vault Agent reads `postgres_password` and `redis_password` from
`secret/data/nexus/identity`.

```bash
docker compose exec vault vault kv put -address=http://127.0.0.1:8200 secret/nexus/identity \
  postgres_password='change-this-postgres-password' \
  redis_password='change-this-redis-password'
```

## 5. Create The Read Policy

```bash
docker compose exec vault sh -lc "cat > /tmp/identity-policy.hcl <<'EOF'
path \"secret/data/nexus/identity\" {
  capabilities = [\"read\"]
}
EOF
vault policy write -address=http://127.0.0.1:8200 identity-read /tmp/identity-policy.hcl"
```

## 6. Enable AppRole

```bash
docker compose exec vault vault auth enable -address=http://127.0.0.1:8200 approle
```

If AppRole is already enabled, Vault returns an error. In that case, continue to
the next step.

## 7. Create The Identity Role

```bash
docker compose exec vault vault write -address=http://127.0.0.1:8200 auth/approle/role/identity \
  policies=identity-read \
  token_ttl=1h \
  token_max_ttl=4h
```

## 8. Generate `vault_role_id`

```bash
docker compose exec vault vault read -address=http://127.0.0.1:8200 -field=role_id \
  auth/approle/role/identity/role-id > secrets/vault_role_id
```

## 9. Generate `vault_secret_id`

```bash
docker compose exec vault vault write -address=http://127.0.0.1:8200 -field=secret_id -f \
  auth/approle/role/identity/secret-id > secrets/vault_secret_id
```

## 10. Start The Full Stack

```bash
docker compose up --build --detach
```

## 11. Verify Vault Agent Rendered Files

```bash
docker compose exec vault_agent ls -l /vault/secrets
```

Expected files:

```text
postgres_password
redis_password
```

Do not commit the real `secrets/` directory.
