#!/usr/bin/env bash

# Projects owns its Vault payload; generic policy and AppRole mechanics are shared.
write_projects_runtime_secrets() {
  info "Writing Projects runtime secrets to Vault..."
  docker compose exec -T vault \
    vault kv put -address="$VAULT_ADDRESS" "$VAULT_SECRET_PATH" \
    postgres_password="$(cat "$POSTGRES_PASSWORD_FILE")" \
    redis_password="$(cat "$REDIS_PASSWORD_FILE")" \
    service_secret="$(cat "$SERVICE_SECRET_FILE")" \
    identity_access_token_public_key_pem="$(read_secret_file_escaped_newlines "$IDENTITY_ACCESS_TOKEN_PUBLIC_KEY_FILE")" \
    project_authorization_grant_secret="$(cat "$PROJECT_AUTHORIZATION_GRANT_SECRET_FILE")" \
    >/dev/null
  success "Runtime secrets written to Vault."
}

configure_projects_policy() { configure_vault_policy; }
configure_projects_approle() { configure_vault_approle; }
