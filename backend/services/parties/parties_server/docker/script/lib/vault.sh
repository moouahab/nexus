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

write_parties_runtime_secrets() {
  info "Writing Parties runtime secrets to Vault..."
  docker compose exec -T vault \
    vault kv put -address="$VAULT_ADDRESS" "$VAULT_SECRET_PATH" \
    postgres_password="$(cat "$POSTGRES_PASSWORD_FILE")" \
    redis_password="$(cat "$REDIS_PASSWORD_FILE")" \
    service_secret="$(cat "$SERVICE_SECRET_FILE")" \
    identity_access_token_public_key_pem="$(cat "$IDENTITY_ACCESS_TOKEN_PUBLIC_KEY_FILE")" \
    >/dev/null
  success "Runtime secrets written to Vault."
}

configure_parties_policy() {
  info "Creating or updating Vault policy: $VAULT_POLICY"

  docker compose exec -T vault sh -c \
    'cat > /tmp/parties-policy.hcl' <<'EOF'
path "secret/data/nexus/parties" {
  capabilities = ["read"]
}
EOF

  docker compose exec -T vault \
    vault policy write -address="$VAULT_ADDRESS" \
    "$VAULT_POLICY" /tmp/parties-policy.hcl >/dev/null
  success "Vault policy is ready."
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

configure_parties_approle() {
  info "Creating or updating AppRole role: $VAULT_ROLE"
  docker compose exec -T vault \
    vault write -address="$VAULT_ADDRESS" \
    "auth/approle/role/$VAULT_ROLE" \
    policies="$VAULT_POLICY" \
    token_ttl=1h \
    token_max_ttl=4h >/dev/null
  success "AppRole role is ready."
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
