#!/usr/bin/env bash

# Shared Vault/AppRole mechanics. Each service remains responsible for the
# values written below VAULT_SECRET_PATH and exposes its own named wrappers.

wait_for_vault() {
  local max_attempts="${VAULT_WAIT_MAX_ATTEMPTS:-30}"
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
  else
    printf '%s' "$default_value"
  fi
}

read_secret_file_escaped_newlines() {
  perl -0pe 's/\n/\\n/g; s/\\n$//' "$1"
}

configure_vault_policy() {
  local policy_file="/tmp/${VAULT_ROLE}-policy.hcl"
  local data_path="${VAULT_SECRET_PATH/secret\//secret/data/}"

  info "Creating or updating Vault policy: $VAULT_POLICY"
  printf 'path "%s" {\n  capabilities = ["read"]\n}\n' "$data_path" |
    docker compose exec -T vault sh -c "cat > '$policy_file'"
  docker compose exec -T vault \
    vault policy write -address="$VAULT_ADDRESS" \
    "$VAULT_POLICY" "$policy_file" >/dev/null
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

configure_vault_approle() {
  info "Creating or updating AppRole role: $VAULT_ROLE"
  docker compose exec -T vault \
    vault write -address="$VAULT_ADDRESS" \
    "auth/approle/role/$VAULT_ROLE" policies="$VAULT_POLICY" \
    token_ttl=1h token_max_ttl=4h >/dev/null
  success "AppRole role is ready."
}

generate_approle_credentials() {
  info "Generating Role ID..."
  docker compose exec -T vault \
    vault read -address="$VAULT_ADDRESS" -field=role_id \
    "auth/approle/role/$VAULT_ROLE/role-id" > "$ROLE_ID_FILE"
  chmod 600 "$ROLE_ID_FILE"
  require_file "$ROLE_ID_FILE"
  success "Role ID written to secrets/vault_role_id."

  info "Generating a new Secret ID..."
  docker compose exec -T vault \
    vault write -address="$VAULT_ADDRESS" -field=secret_id -f \
    "auth/approle/role/$VAULT_ROLE/secret-id" > "$SECRET_ID_FILE"
  chmod 600 "$SECRET_ID_FILE"
  require_file "$SECRET_ID_FILE"
  success "Secret ID written to secrets/vault_secret_id."
}
