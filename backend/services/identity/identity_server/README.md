# identity_server

This is the starting point for your Serverpod server.

To run your server, you first need to start Postgres and Redis. It's easiest to do with Docker.

    docker compose up --build --detach

Then you can start the Serverpod server.

    dart bin/main.dart

When you are finished, you can shut down Serverpod with `Ctrl-C`, then stop Postgres and Redis.

    docker compose stop

## Vault Agent

The Docker stack runs a Vault Agent sidecar. It authenticates with AppRole,
reads the KV v2 secret at `secret/data/nexus/identity`, and renders files used
by Postgres, Redis, and the API:

- `postgres_password` from `postgres_password`
- `redis_password` from `redis_password`
- `serverpod-passwords.yaml` from the full Serverpod secret set

For an existing Vault, create local AppRole files first:

    cp -r secrets_example secrets
    printf '%s' '<role-id>' > secrets/vault_role_id
    printf '%s' '<secret-id>' > secrets/vault_secret_id

For a fresh local development Vault, start Vault first and generate these files
after creating AppRole:

    cp -r secrets_example secrets
    printf '%s' '<dev-root-token>' > secrets/vault_dev_root_token
    docker compose up --build --detach vault

Then initialize the local secret, policy, and AppRole:

    docker compose exec vault vault login -address=http://127.0.0.1:8200 "$(cat secrets/vault_dev_root_token)"
    docker compose exec vault vault kv put -address=http://127.0.0.1:8200 secret/nexus/identity \
      postgres_password='postgres-password' \
      redis_password='redis-password' \
      service_secret='<serverpod-service-secret>' \
      email_secret_hash_pepper='<email-secret-hash-pepper>' \
      jwt_hmac_sha512_private_key='<jwt-hmac-sha512-private-key>' \
      jwt_refresh_token_hash_pepper='<jwt-refresh-token-hash-pepper>'
    docker compose exec vault sh -lc "cat > /tmp/identity-policy.hcl <<'EOF'
path \"secret/data/nexus/identity\" {
  capabilities = [\"read\"]
}
EOF
vault policy write -address=http://127.0.0.1:8200 identity-read /tmp/identity-policy.hcl"
    docker compose exec vault vault auth enable -address=http://127.0.0.1:8200 approle
    docker compose exec vault vault write -address=http://127.0.0.1:8200 auth/approle/role/identity policies=identity-read token_ttl=1h token_max_ttl=4h
    docker compose exec vault vault read -address=http://127.0.0.1:8200 -field=role_id auth/approle/role/identity/role-id > secrets/vault_role_id
    docker compose exec vault vault write -address=http://127.0.0.1:8200 -field=secret_id -f auth/approle/role/identity/secret-id > secrets/vault_secret_id

The API does not mount or read `config/passwords.yaml` from the host in Docker.
It reads `/run/vault/secrets/serverpod-passwords.yaml`, rendered by Vault Agent.
The local Vault secret must contain all of these keys:

- `postgres_password`
- `redis_password`
- `service_secret`
- `email_secret_hash_pepper`
- `jwt_hmac_sha512_private_key`
- `jwt_refresh_token_hash_pepper`

Start the stack:

    docker compose up --build --detach

The local development Vault server listens on `http://127.0.0.1:8200` from the
host and on `http://vault:8200` from Docker Compose.

Postgres, Redis, and the API wait for the rendered Vault Agent files before
starting.

If an older run created `config/passwords.yaml` as a directory, remove that
directory. It was created by Docker when a bind mount pointed at a missing host
file; the current Docker setup no longer uses that mount.

See `docker/vault/docs/generate-approle-secrets.md` for the full reproducible
procedure.

See `docker/vault/docs/vault-agent-troubleshooting-notes.md` for the issues
encountered while building this Vault Agent setup and their fixes.

See `docker/vault/docs/production-vault-setup.md` for the production Vault
deployment procedure.

See `docker/vault/docs/rotate-secrets.md` for secret rotation.

See `docker/vault/docs/production-monitoring.md` for production monitoring and
alerting.

See `docker/vault/docs/inject-approle-secrets.md` for production AppRole secret
injection.
