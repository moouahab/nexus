#!/usr/bin/env bash

prepare_local_secrets() {
  mkdir -p "$SECRETS_DIR"
  ensure_secret_file "$ROOT_TOKEN_FILE" "Local Vault dev root token" "change-this-dev-root-token"
  ensure_secret_file "$ROLE_ID_FILE" "Initial Vault role id" "pending-bootstrap"
  ensure_secret_file "$SECRET_ID_FILE" "Initial Vault secret id" "pending-bootstrap"
  ensure_secret_file "$POSTGRES_PASSWORD_FILE" "PostgreSQL password"
  ensure_secret_file "$SERVICE_SECRET_FILE" "Serverpod service secret"
  ensure_secret_file "$IDENTITY_SERVICE_CLIENT_ID_FILE" "Identity service client id" "ai-gateway"
  ensure_secret_file "$IDENTITY_SERVICE_CLIENT_SECRET_FILE" "Identity service client secret"
  cp "$BACKEND_ROOT/services/identity/identity_server/secrets/jwt_access_token_public_key_pem" \
    "$IDENTITY_ACCESS_TOKEN_PUBLIC_KEY_FILE"
  chmod 600 "$IDENTITY_ACCESS_TOKEN_PUBLIC_KEY_FILE"
}

print_success_summary() {
  cat <<'EOF'

AI Gateway Vault initialization complete.
Generated secrets and Vault Agent runtime files are ready.
EOF
}
