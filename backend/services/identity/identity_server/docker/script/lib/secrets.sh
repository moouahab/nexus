#!/usr/bin/env bash

copy_examples_if_needed() {
  if [[ -d "$SECRETS_DIR" ]]; then
    info "secrets/ already exists: it will not be overwritten."
    return 0
  fi

  if [[ -d "$SECRETS_EXAMPLE_DIR" ]]; then
    info "Creating secrets/ from secrets_example/..."
    cp -R "$SECRETS_EXAMPLE_DIR" "$SECRETS_DIR"
    success "secrets/ created."
    return 0
  fi

  info "Creating empty secrets/ directory..."
  mkdir -p "$SECRETS_DIR"
  success "secrets/ created."
}

ensure_secret_file() {
  local path="$1"
  local label="$2"
  local value="${3:-}"

  if [[ -s "$path" ]]; then
    info "$label already exists."
    chmod 600 "$path"
    return 0
  fi

  if [[ -n "$value" ]]; then
    printf '%s' "$value" > "$path"
  else
    random_secret > "$path"
  fi

  chmod 600 "$path"
  success "$label created."
}

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
  ensure_secret_file "$EMAIL_SECRET_HASH_PEPPER_FILE" "Email/password hash pepper"
  ensure_secret_file "$JWT_HMAC_PRIVATE_KEY_FILE" "JWT HMAC private key"
  ensure_secret_file "$JWT_REFRESH_HASH_PEPPER_FILE" "JWT refresh token hash pepper"

  require_file "$ROOT_TOKEN_FILE"
  require_file "$POSTGRES_PASSWORD_FILE"
  require_file "$REDIS_PASSWORD_FILE"
  require_file "$SERVICE_SECRET_FILE"
  require_file "$EMAIL_SECRET_HASH_PEPPER_FILE"
  require_file "$JWT_HMAC_PRIVATE_KEY_FILE"
  require_file "$JWT_REFRESH_HASH_PEPPER_FILE"
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
  - secrets/email_secret_hash_pepper
  - secrets/jwt_hmac_sha512_private_key
  - secrets/jwt_refresh_token_hash_pepper

Files rendered by Vault Agent:
  - /vault/secrets/postgres_password
  - /vault/secrets/redis_password
  - /vault/secrets/serverpod-passwords.yaml

Important:
  - never commit the real secrets/ directory;
  - local Vault dev mode loses data when its ephemeral storage is removed.
EOF
}
