#!/usr/bin/env bash

readonly SERVER_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
readonly SECRETS_DIR="$SERVER_ROOT/secrets"
readonly SECRETS_EXAMPLE_DIR="$SERVER_ROOT/secrets_example"

readonly VAULT_ADDRESS="${VAULT_ADDRESS:-http://127.0.0.1:8200}"
readonly VAULT_POLICY="${VAULT_POLICY:-parties-read}"
readonly VAULT_ROLE="${VAULT_ROLE:-parties}"
readonly VAULT_SECRET_PATH="${VAULT_SECRET_PATH:-secret/nexus/parties}"

readonly ROOT_TOKEN_FILE="$SECRETS_DIR/vault_dev_root_token"
readonly ROLE_ID_FILE="$SECRETS_DIR/vault_role_id"
readonly SECRET_ID_FILE="$SECRETS_DIR/vault_secret_id"
readonly POSTGRES_PASSWORD_FILE="$SECRETS_DIR/postgres_password"
readonly REDIS_PASSWORD_FILE="$SECRETS_DIR/redis_password"
readonly SERVICE_SECRET_FILE="$SECRETS_DIR/service_secret"
readonly IDENTITY_ACCESS_TOKEN_PUBLIC_KEY_FILE="$SECRETS_DIR/identity_access_token_public_key_pem"

setup_environment() {
  cd "$SERVER_ROOT"
  umask 077

  if [[ ! -f "$SERVER_ROOT/docker-compose.yaml" ]]; then
    error "docker-compose.yaml not found in: $SERVER_ROOT"
    exit 1
  fi
}
