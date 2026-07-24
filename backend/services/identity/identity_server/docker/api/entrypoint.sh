#!/bin/sh

set -eu

vault_passwords_source="/run/vault/secrets/serverpod-passwords.yaml"
passwords_source="${SERVERPOD_PASSWORDS_SOURCE:-}"
database_password_file="${DATABASE_PASSWORD_FILE:-/run/vault/secrets/postgres_password}"
redis_password_file="${REDIS_PASSWORD_FILE:-/run/vault/secrets/redis_password}"
passwords_target="/app/config/passwords.yaml"
mode="${1:-${runmode:-development}}"
server_id="${2:-${serverid:-default}}"
log_level="${3:-${logging:-normal}}"
server_role="${4:-${role:-monolith}}"
should_apply_migrations="${5:-${apply_migrations:-false}}"
secret_wait_timeout="${SECRET_WAIT_TIMEOUT_SECONDS:-60}"

wait_for_readable_file() {
  path="$1"
  label="$2"
  elapsed=0

  while [ ! -r "$path" ]; do
    if [ "$elapsed" -ge "$secret_wait_timeout" ]; then
      echo "$label introuvable." >&2
      exit 1
    fi

    sleep 1
    elapsed=$((elapsed + 1))
  done
}

if [ -z "$passwords_source" ]; then
  if [ -r "$vault_passwords_source" ]; then
    passwords_source="$vault_passwords_source"
  else
    passwords_source="/run/config/serverpod-passwords.yaml"
  fi
fi

if [ ! -r "$passwords_source" ]; then
  echo "Configuration Serverpod passwords introuvable." >&2
  exit 1
fi

if [ "$passwords_source" = "$vault_passwords_source" ]; then
  cp "$passwords_source" "$passwords_target"
else

  wait_for_readable_file "$database_password_file" "Secret PostgreSQL"
  wait_for_readable_file "$redis_password_file" "Secret Redis"

  database_password="$(tr -d '\r\n' < "$database_password_file")"
  redis_password="$(tr -d '\r\n' < "$redis_password_file")"

  if [ -z "$database_password" ]; then
    echo "Secret PostgreSQL vide." >&2
    exit 1
  fi

  if [ -z "$redis_password" ]; then
    echo "Secret Redis vide." >&2
    exit 1
  fi

  awk -v mode="$mode" -v database_password="$database_password" -v redis_password="$redis_password" '
    $0 == mode ":" {
      in_mode = 1
    }

    /^[^[:space:]][[:alnum:]_]*:/ && $0 != mode ":" {
      in_mode = 0
    }

    in_mode && /^[[:space:]]+database:/ {
      sub(/:.*/, ": \047" database_password "\047")
    }

    in_mode && /^[[:space:]]+redis:/ {
      sub(/:.*/, ": \047" redis_password "\047")
    }

    { print }
  ' "$passwords_source" > "$passwords_target"
fi

set -- ./server --mode="$mode" --server-id="$server_id" --logging="$log_level" --role="$server_role"

if [ "$should_apply_migrations" = "true" ]; then
  set -- "$@" --apply-migrations
fi

exec "$@"
