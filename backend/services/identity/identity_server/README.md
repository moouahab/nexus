# Identity Server

`identity_server` owns authentication for NEXUS.

It owns:

- the `identity` database;
- username/password authentication;
- email verification and password reset;
- OAuth provider configuration;
- JWT/access token and refresh token secrets;
- SMTP mail delivery configuration.

Other services must not copy these auth secrets.

## Local Runtime

Use the local setup script from `identity_server/`:

```bash
./docker/script/setup_vault_approle.sh
```

The script creates or reuses local secrets, writes the Identity secret set to
Vault, configures AppRole, starts the Docker stack, and verifies Vault Agent
output.

Runtime ports:

```text
API      127.0.0.1:8080
Insights 127.0.0.1:8181
Web      127.0.0.1:8182
Postgres 127.0.0.1:8090
Redis    127.0.0.1:8091
Vault    127.0.0.1:8200
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

Still specific to `identity`:

- Compose ports, volumes, names, and DB name;
- `docker/script/lib/paths.sh`;
- `docker/script/lib/secrets.sh`;
- `docker/script/lib/vault.sh`;
- `docker/vault/templates/`;
- `secrets/` and `secrets_example/`.

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
- `jwt_access_token_private_key_pem`
- `jwt_access_token_public_key_pem`
- `jwt_access_token_key_id`
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

Access tokens are signed with RS256 when `jwt_access_token_private_key_pem`
and `jwt_access_token_public_key_pem` are configured. The public key is exposed
through `/.well-known/jwks.json` so other services and Kong can validate tokens
without receiving signing material. `jwt_hmac_sha512_private_key` remains as a
legacy fallback during migration.

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

For local Google login, write the Google web/server OAuth client values to Identity
secrets, then re-run the setup so Vault and the containers receive them:

```bash
printf '%s' 'true' > secrets/google_oauth_enabled
printf '%s' '<web-client-id>' > secrets/google_oauth_client_id
printf '%s' '<web-client-secret>' > secrets/google_oauth_client_secret
./docker/script/setup_vault_approle.sh
```

Restart the frontend with the same server client id:

```bash
flutter run \
  --dart-define=GOOGLE_OAUTH_ANDROID_CLIENT_ID='<android-client-id>' \
  --dart-define=GOOGLE_OAUTH_IOS_CLIENT_ID='<ios-client-id>' \
  --dart-define=GOOGLE_OAUTH_WEB_CLIENT_ID='<web-client-id>' \
  --dart-define=GOOGLE_OAUTH_SERVER_CLIENT_ID='<web-client-id>'
```

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

Shared Vault operational rules live in
`backend/infrastructure/service-runtime/docs/vault-operations.md`.

## Tests

Run from `identity_server/`:

```bash
./docker/script/run_serverpod_tests.sh
```

The wrapper delegates to the shared Serverpod test runner and enables
`SERVERPOD_TEST_AUTH_PASSWORDS=true`, because Identity owns the auth test
secrets.
