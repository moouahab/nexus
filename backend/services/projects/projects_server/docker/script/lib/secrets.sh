#!/usr/bin/env bash

prepare_local_secrets() {
  copy_examples_if_needed
  mkdir -p "$SECRETS_DIR"

  ensure_secret_file \
    "$ROOT_TOKEN_FILE" \
    "Local Vault dev root token" \
    "${VAULT_DEV_ROOT_TOKEN:-change-this-dev-root-token}"
  ensure_secret_file "$POSTGRES_PASSWORD_FILE" "PostgreSQL password"
  ensure_secret_file "$REDIS_PASSWORD_FILE" "Redis password"
  ensure_secret_file "$SERVICE_SECRET_FILE" "Serverpod service secret"

  require_file "$ROOT_TOKEN_FILE"
  require_file "$POSTGRES_PASSWORD_FILE"
  require_file "$REDIS_PASSWORD_FILE"
  require_file "$SERVICE_SECRET_FILE"
  require_file "$IDENTITY_ACCESS_TOKEN_PUBLIC_KEY_FILE"
  require_file "$PROJECT_AUTHORIZATION_GRANT_SECRET_FILE"
}

print_success_summary() {
  cat <<'EOF'

Initialization complete.

Local files created or updated:
  - secrets/vault_role_id
  - secrets/vault_secret_id

Runtime secret source files:
  - secrets/postgres_password
  - secrets/redis_password
  - secrets/service_secret
  - secrets/identity_access_token_public_key_pem
  - Identity secrets/project_authorization_grant_secret (shared, never generated here)

Files rendered by Vault Agent:
  - /vault/secrets/postgres/postgres_password
  - /vault/secrets/redis/redis_password
  - /vault/secrets/api/serverpod-passwords.yaml

Important:
  - never commit the real secrets/ directory;
  - local Vault dev mode loses data when its ephemeral storage is removed.
EOF
}
