#!/usr/bin/env bash

write_ai_gateway_runtime_secrets() {
  info "Writing AI Gateway runtime secrets to Vault..."
  docker compose exec -T vault \
    vault kv put -address="$VAULT_ADDRESS" "$VAULT_SECRET_PATH" \
    postgres_password="$(cat "$POSTGRES_PASSWORD_FILE")" \
    redis_password="" \
    service_secret="$(cat "$SERVICE_SECRET_FILE")" \
    identity_access_token_public_key_pem="$(read_secret_file_escaped_newlines "$IDENTITY_ACCESS_TOKEN_PUBLIC_KEY_FILE")" \
    identity_service_client_id="$(cat "$IDENTITY_SERVICE_CLIENT_ID_FILE")" \
    identity_service_client_secret="$(cat "$IDENTITY_SERVICE_CLIENT_SECRET_FILE")" \
    >/dev/null
  success "Runtime secrets written to Vault."
}

configure_ai_gateway_policy() { configure_vault_policy; }
configure_ai_gateway_approle() { configure_vault_approle; }
