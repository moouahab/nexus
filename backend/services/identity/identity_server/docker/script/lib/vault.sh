#!/usr/bin/env bash

wait_for_vault() {
  local max_attempts=30
  local attempt=1

  info "Waiting for Vault..."

  while (( attempt <= max_attempts )); do
    if docker compose exec -T vault \
      vault status -address="$VAULT_ADDRESS" >/dev/null 2>&1; then
      success "Vault is ready."
      return 0
    fi

    sleep 2
    ((attempt++))
  done

  error "Vault did not become ready."
  docker compose logs --tail=100 vault || true
  exit 1
}

vault_login() {
  info "Logging into Vault..."
  docker compose exec -T vault \
    vault login -address="$VAULT_ADDRESS" \
    "$(cat "$ROOT_TOKEN_FILE")" >/dev/null
  success "Vault login succeeded."
}

read_secret_file_or_default() {
  local path="$1"
  local default_value="${2:-}"

  if [[ -e "$path" ]]; then
    cat "$path"
    return 0
  fi

  printf '%s' "$default_value"
}

read_secret_file_escaped_newlines() {
  local path="$1"

  perl -0pe 's/\n/\\n/g; s/\\n$//' "$path"
}

write_identity_runtime_secrets() {
  info "Writing Identity runtime secrets to Vault..."
  docker compose exec -T vault \
    vault kv put -address="$VAULT_ADDRESS" "$VAULT_SECRET_PATH" \
    postgres_password="$(cat "$POSTGRES_PASSWORD_FILE")" \
    redis_password="$(cat "$REDIS_PASSWORD_FILE")" \
    service_secret="$(cat "$SERVICE_SECRET_FILE")" \
    email_secret_hash_pepper="$(cat "$EMAIL_SECRET_HASH_PEPPER_FILE")" \
    jwt_access_token_private_key_pem="$(read_secret_file_escaped_newlines "$JWT_ACCESS_TOKEN_PRIVATE_KEY_FILE")" \
    jwt_access_token_public_key_pem="$(read_secret_file_escaped_newlines "$JWT_ACCESS_TOKEN_PUBLIC_KEY_FILE")" \
    jwt_access_token_key_id="$(read_secret_file_or_default "$JWT_ACCESS_TOKEN_KEY_ID_FILE" "identity-access-token-current")" \
    jwt_hmac_sha512_private_key="$(cat "$JWT_HMAC_PRIVATE_KEY_FILE")" \
    jwt_refresh_token_hash_pepper="$(cat "$JWT_REFRESH_HASH_PEPPER_FILE")" \
    project_authorization_grant_secret="$(cat "$PROJECT_AUTHORIZATION_GRANT_SECRET_FILE")" \
    auth_allowed_origins="$(read_secret_file_or_default "$AUTH_ALLOWED_ORIGINS_FILE" "")" \
    auth_service_clients="$(read_secret_file_or_default "$AUTH_SERVICE_CLIENTS_FILE" "{}")" \
    mail_from_address="$(read_secret_file_or_default "$MAIL_FROM_ADDRESS_FILE" "no-reply@nexus.example")" \
    mail_from_name="$(read_secret_file_or_default "$MAIL_FROM_NAME_FILE" "Nexus")" \
    mail_support_address="$(read_secret_file_or_default "$MAIL_SUPPORT_ADDRESS_FILE" "support@nexus.example")" \
    smtp_host="$(read_secret_file_or_default "$SMTP_HOST_FILE" "")" \
    smtp_port="$(read_secret_file_or_default "$SMTP_PORT_FILE" "587")" \
    smtp_username="$(read_secret_file_or_default "$SMTP_USERNAME_FILE" "")" \
    smtp_password="$(read_secret_file_or_default "$SMTP_PASSWORD_FILE" "")" \
    google_oauth_enabled="$(read_secret_file_or_default "$GOOGLE_OAUTH_ENABLED_FILE" "${GOOGLE_OAUTH_ENABLED:-false}")" \
    google_oauth_client_id="$(read_secret_file_or_default "$GOOGLE_OAUTH_CLIENT_ID_FILE" "${GOOGLE_OAUTH_CLIENT_ID:-}")" \
    google_oauth_client_secret="$(read_secret_file_or_default "$GOOGLE_OAUTH_CLIENT_SECRET_FILE" "${GOOGLE_OAUTH_CLIENT_SECRET:-}")" \
    github_oauth_enabled="$(read_secret_file_or_default "$GITHUB_OAUTH_ENABLED_FILE" "${GITHUB_OAUTH_ENABLED:-false}")" \
    github_oauth_client_id="$(read_secret_file_or_default "$GITHUB_OAUTH_CLIENT_ID_FILE" "${GITHUB_OAUTH_CLIENT_ID:-}")" \
    github_oauth_client_secret="$(read_secret_file_or_default "$GITHUB_OAUTH_CLIENT_SECRET_FILE" "${GITHUB_OAUTH_CLIENT_SECRET:-}")" \
    apple_oauth_enabled="$(read_secret_file_or_default "$APPLE_OAUTH_ENABLED_FILE" "${APPLE_OAUTH_ENABLED:-false}")" \
    apple_oauth_client_id="$(read_secret_file_or_default "$APPLE_OAUTH_CLIENT_ID_FILE" "${APPLE_OAUTH_CLIENT_ID:-}")" \
    apple_oauth_client_secret="$(read_secret_file_or_default "$APPLE_OAUTH_CLIENT_SECRET_FILE" "${APPLE_OAUTH_CLIENT_SECRET:-}")" \
    >/dev/null
  success "Runtime secrets written to Vault."
}

configure_identity_policy() {
  configure_vault_policy
}

ensure_approle_auth_enabled() {
  info "Checking AppRole auth method..."

  if docker compose exec -T vault \
    vault auth list -address="$VAULT_ADDRESS" 2>/dev/null |
    grep -qE '^approle/[[:space:]]'; then
    info "AppRole is already enabled."
    return 0
  fi

  docker compose exec -T vault \
    vault auth enable -address="$VAULT_ADDRESS" approle >/dev/null
  success "AppRole enabled."
}

configure_identity_approle() {
  configure_vault_approle
}

generate_approle_credentials() {
  generate_role_id
  generate_secret_id
}

generate_role_id() {
  info "Generating Role ID..."
  docker compose exec -T vault \
    vault read -address="$VAULT_ADDRESS" -field=role_id \
    "auth/approle/role/$VAULT_ROLE/role-id" \
    > "$ROLE_ID_FILE"

  chmod 600 "$ROLE_ID_FILE"
  require_file "$ROLE_ID_FILE"
  success "Role ID written to secrets/vault_role_id."
}

generate_secret_id() {
  info "Generating a new Secret ID..."
  docker compose exec -T vault \
    vault write -address="$VAULT_ADDRESS" -field=secret_id -f \
    "auth/approle/role/$VAULT_ROLE/secret-id" \
    > "$SECRET_ID_FILE"

  chmod 600 "$SECRET_ID_FILE"
  require_file "$SECRET_ID_FILE"
  success "Secret ID written to secrets/vault_secret_id."
}
