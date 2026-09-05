#!/usr/bin/env bash

readonly SERVER_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
readonly SECRETS_DIR="$SERVER_ROOT/secrets"
readonly SECRETS_EXAMPLE_DIR="$SERVER_ROOT/secrets_example"

readonly VAULT_ADDRESS="${VAULT_ADDRESS:-http://127.0.0.1:8200}"
readonly VAULT_POLICY="${VAULT_POLICY:-identity-read}"
readonly VAULT_ROLE="${VAULT_ROLE:-identity}"
readonly VAULT_SECRET_PATH="${VAULT_SECRET_PATH:-secret/nexus/identity}"

readonly ROOT_TOKEN_FILE="$SECRETS_DIR/vault_dev_root_token"
readonly ROLE_ID_FILE="$SECRETS_DIR/vault_role_id"
readonly SECRET_ID_FILE="$SECRETS_DIR/vault_secret_id"
readonly POSTGRES_PASSWORD_FILE="$SECRETS_DIR/postgres_password"
readonly REDIS_PASSWORD_FILE="$SECRETS_DIR/redis_password"
readonly SERVICE_SECRET_FILE="$SECRETS_DIR/service_secret"
readonly EMAIL_SECRET_HASH_PEPPER_FILE="$SECRETS_DIR/email_secret_hash_pepper"
readonly JWT_HMAC_PRIVATE_KEY_FILE="$SECRETS_DIR/jwt_hmac_sha512_private_key"
readonly JWT_REFRESH_HASH_PEPPER_FILE="$SECRETS_DIR/jwt_refresh_token_hash_pepper"
readonly AUTH_ALLOWED_ORIGINS_FILE="$SECRETS_DIR/auth_allowed_origins"
readonly MAIL_FROM_ADDRESS_FILE="$SECRETS_DIR/mail_from_address"
readonly MAIL_FROM_NAME_FILE="$SECRETS_DIR/mail_from_name"
readonly MAIL_SUPPORT_ADDRESS_FILE="$SECRETS_DIR/mail_support_address"
readonly SMTP_HOST_FILE="$SECRETS_DIR/smtp_host"
readonly SMTP_PORT_FILE="$SECRETS_DIR/smtp_port"
readonly SMTP_USERNAME_FILE="$SECRETS_DIR/smtp_username"
readonly SMTP_PASSWORD_FILE="$SECRETS_DIR/smtp_password"
readonly GOOGLE_OAUTH_ENABLED_FILE="$SECRETS_DIR/google_oauth_enabled"
readonly GOOGLE_OAUTH_CLIENT_ID_FILE="$SECRETS_DIR/google_oauth_client_id"
readonly GOOGLE_OAUTH_CLIENT_SECRET_FILE="$SECRETS_DIR/google_oauth_client_secret"
readonly GITHUB_OAUTH_ENABLED_FILE="$SECRETS_DIR/github_oauth_enabled"
readonly GITHUB_OAUTH_CLIENT_ID_FILE="$SECRETS_DIR/github_oauth_client_id"
readonly GITHUB_OAUTH_CLIENT_SECRET_FILE="$SECRETS_DIR/github_oauth_client_secret"
readonly APPLE_OAUTH_ENABLED_FILE="$SECRETS_DIR/apple_oauth_enabled"
readonly APPLE_OAUTH_CLIENT_ID_FILE="$SECRETS_DIR/apple_oauth_client_id"
readonly APPLE_OAUTH_CLIENT_SECRET_FILE="$SECRETS_DIR/apple_oauth_client_secret"

setup_environment() {
  cd "$SERVER_ROOT"
  umask 077

  if [[ ! -f "$SERVER_ROOT/docker-compose.yaml" ]]; then
    error "docker-compose.yaml not found in: $SERVER_ROOT"
    exit 1
  fi
}
