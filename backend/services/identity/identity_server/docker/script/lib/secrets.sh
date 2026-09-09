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

ensure_config_file() {
  local path="$1"
  local label="$2"
  local value="${3:-}"

  if [[ -e "$path" ]]; then
    info "$label already exists."
    chmod 600 "$path"
    return 0
  fi

  printf '%s' "$value" > "$path"
  chmod 600 "$path"
  success "$label created."
}

ensure_rsa_key_pair() {
  if [[ -s "$JWT_ACCESS_TOKEN_PRIVATE_KEY_FILE" && -s "$JWT_ACCESS_TOKEN_PUBLIC_KEY_FILE" ]]; then
    info "JWT access token RSA key pair already exists."
    chmod 600 "$JWT_ACCESS_TOKEN_PRIVATE_KEY_FILE" "$JWT_ACCESS_TOKEN_PUBLIC_KEY_FILE"
    return 0
  fi

  if ! command -v openssl >/dev/null 2>&1; then
    error "openssl is required to generate the local JWT RSA key pair."
    exit 1
  fi

  info "Generating local JWT access token RSA key pair..."
  openssl genpkey \
    -algorithm RSA \
    -pkeyopt rsa_keygen_bits:2048 \
    -out "$JWT_ACCESS_TOKEN_PRIVATE_KEY_FILE" >/dev/null 2>&1
  openssl rsa \
    -pubout \
    -in "$JWT_ACCESS_TOKEN_PRIVATE_KEY_FILE" \
    -out "$JWT_ACCESS_TOKEN_PUBLIC_KEY_FILE" >/dev/null 2>&1
  chmod 600 "$JWT_ACCESS_TOKEN_PRIVATE_KEY_FILE" "$JWT_ACCESS_TOKEN_PUBLIC_KEY_FILE"
  success "JWT access token RSA key pair created."
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
  ensure_rsa_key_pair
  ensure_config_file "$JWT_ACCESS_TOKEN_KEY_ID_FILE" "JWT access token key id" "identity-access-token-current"
  ensure_secret_file "$JWT_HMAC_PRIVATE_KEY_FILE" "JWT HMAC private key"
  ensure_secret_file "$JWT_REFRESH_HASH_PEPPER_FILE" "JWT refresh token hash pepper"
  ensure_config_file "$AUTH_ALLOWED_ORIGINS_FILE" "Auth allowed origins" ""
  ensure_config_file "$MAIL_FROM_ADDRESS_FILE" "Mail from address" "no-reply@nexus.example"
  ensure_config_file "$MAIL_FROM_NAME_FILE" "Mail from name" "Nexus"
  ensure_config_file "$MAIL_SUPPORT_ADDRESS_FILE" "Mail support address" "support@nexus.example"
  ensure_config_file "$SMTP_HOST_FILE" "SMTP host" ""
  ensure_config_file "$SMTP_PORT_FILE" "SMTP port" "587"
  ensure_config_file "$SMTP_USERNAME_FILE" "SMTP username" ""
  ensure_config_file "$SMTP_PASSWORD_FILE" "SMTP password" ""

  require_file "$ROOT_TOKEN_FILE"
  require_file "$POSTGRES_PASSWORD_FILE"
  require_file "$REDIS_PASSWORD_FILE"
  require_file "$SERVICE_SECRET_FILE"
  require_file "$EMAIL_SECRET_HASH_PEPPER_FILE"
  require_file "$JWT_ACCESS_TOKEN_PRIVATE_KEY_FILE"
  require_file "$JWT_ACCESS_TOKEN_PUBLIC_KEY_FILE"
  require_file "$JWT_ACCESS_TOKEN_KEY_ID_FILE"
  require_file "$JWT_HMAC_PRIVATE_KEY_FILE"
  require_file "$JWT_REFRESH_HASH_PEPPER_FILE"
  require_file "$MAIL_FROM_ADDRESS_FILE"
  require_file "$MAIL_FROM_NAME_FILE"
  require_file "$MAIL_SUPPORT_ADDRESS_FILE"
  require_file "$SMTP_PORT_FILE"
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
  - secrets/jwt_access_token_private_key_pem
  - secrets/jwt_access_token_public_key_pem
  - secrets/jwt_access_token_key_id
  - secrets/jwt_hmac_sha512_private_key
  - secrets/jwt_refresh_token_hash_pepper
  - secrets/auth_allowed_origins
  - secrets/mail_from_address
  - secrets/mail_from_name
  - secrets/mail_support_address
  - secrets/smtp_host
  - secrets/smtp_port
  - secrets/smtp_username
  - secrets/smtp_password
  - secrets/google_oauth_enabled
  - secrets/google_oauth_client_id
  - secrets/google_oauth_client_secret
  - secrets/github_oauth_enabled
  - secrets/github_oauth_client_id
  - secrets/github_oauth_client_secret
  - secrets/apple_oauth_enabled
  - secrets/apple_oauth_client_id
  - secrets/apple_oauth_client_secret

Files rendered by Vault Agent:
  - /vault/secrets/postgres_password
  - /vault/secrets/redis_password
  - /vault/secrets/serverpod-passwords.yaml

Important:
  - never commit the real secrets/ directory;
  - local Vault dev mode loses data when its ephemeral storage is removed.
EOF
}
