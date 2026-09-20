#!/usr/bin/env bash

readonly SERVER_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
readonly SECRETS_DIR="$SERVER_ROOT/secrets"
readonly SECRETS_EXAMPLE_DIR="$SERVER_ROOT/secrets_example"
readonly VAULT_ADDRESS="${VAULT_ADDRESS:-http://127.0.0.1:8200}"
readonly VAULT_POLICY="${VAULT_POLICY:-ai-gateway-read}"
readonly VAULT_ROLE="${VAULT_ROLE:-ai-gateway}"
readonly VAULT_SECRET_PATH="${VAULT_SECRET_PATH:-secret/nexus/ai_gateway}"
readonly VAULT_AGENT_REQUIRES_REDIS=false

readonly ROOT_TOKEN_FILE="$SECRETS_DIR/vault_dev_root_token"
readonly ROLE_ID_FILE="$SECRETS_DIR/vault_role_id"
readonly SECRET_ID_FILE="$SECRETS_DIR/vault_secret_id"
readonly POSTGRES_PASSWORD_FILE="$SECRETS_DIR/postgres_password"
readonly SERVICE_SECRET_FILE="$SECRETS_DIR/service_secret"
readonly IDENTITY_ACCESS_TOKEN_PUBLIC_KEY_FILE="$SECRETS_DIR/identity_access_token_public_key_pem"
readonly IDENTITY_SERVICE_CLIENT_ID_FILE="$SECRETS_DIR/identity_service_client_id"
readonly IDENTITY_SERVICE_CLIENT_SECRET_FILE="$SECRETS_DIR/identity_service_client_secret"

setup_environment() {
  cd "$SERVER_ROOT"
  umask 077
  require_file "$BACKEND_ROOT/services/identity/identity_server/secrets/jwt_access_token_public_key_pem"
}
