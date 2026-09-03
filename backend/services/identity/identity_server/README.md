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
after creating AppRole. The reproducible local procedure is automated by:

    ./docker/script/setup_vault_approle.sh

The script creates missing local secrets, starts Vault, writes the Identity
runtime secret, configures the read policy, configures AppRole, generates
`vault_role_id` and `vault_secret_id`, starts the full Docker stack, and verifies
Vault Agent output.

The API does not mount or read `config/passwords.yaml` from the host in Docker.
It reads `/run/vault/secrets/serverpod-passwords.yaml`, rendered by Vault Agent.
The local Vault secret must contain all of these keys:

- `postgres_password`
- `redis_password`
- `service_secret`
- `email_secret_hash_pepper`
- `jwt_hmac_sha512_private_key`
- `jwt_refresh_token_hash_pepper`
- `auth_allowed_origins`
- `mail_from_address`
- `mail_from_name`
- `mail_support_address`
- `smtp_host`
- `smtp_port`
- `smtp_username`
- `smtp_password`

OAuth provider keys are prepared but disabled by default:

- `google_oauth_enabled`
- `google_oauth_client_id`
- `google_oauth_client_secret`
- `github_oauth_enabled`
- `github_oauth_client_id`
- `github_oauth_client_secret`
- `apple_oauth_enabled`
- `apple_oauth_client_id`
- `apple_oauth_client_secret`

Set a provider's `_enabled` value to `true` only after its external OAuth app,
secret, and redirect URI are ready.

Set `auth_allowed_origins` to a comma-separated browser origin allowlist, for
example `https://app.nexus.example`. Auth requests with an `Origin` header
outside this allowlist are rejected by the API.

See `docker/proxy/Caddyfile.example` for a staging/production reverse proxy
template with HTTPS, security headers, and credentialed CORS for `/auth/*`.

If you use `./docker/script/setup_vault_approle.sh`, the stack is already
started by the script. If you inject AppRole files manually for an existing
Vault, start the stack with:

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
