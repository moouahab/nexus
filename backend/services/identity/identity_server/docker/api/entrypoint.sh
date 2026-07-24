#!/bin/sh

set -eu

passwords_source="${SERVERPOD_PASSWORDS_SOURCE:-/run/config/serverpod-passwords.yaml}"
database_password_file="${DATABASE_PASSWORD_FILE:-/run/secrets/postgres_password}"
redis_password_file="${REDIS_PASSWORD_FILE:-/run/secrets/redis_password}"
passwords_target="/app/config/passwords.yaml"
mode="${runmode:-development}"

if [ ! -r "$passwords_source" ]; then
  echo "Configuration Serverpod passwords introuvable." >&2
  exit 1
fi

if [ ! -r "$database_password_file" ]; then
  echo "Secret PostgreSQL introuvable." >&2
  exit 1
fi

if [ ! -r "$redis_password_file" ]; then
  echo "Secret Redis introuvable." >&2
  exit 1
fi

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

set -- ./server --mode="$mode" --server-id="$serverid" --logging="$logging" --role="$role"

if [ "${apply_migrations:-false}" = "true" ]; then
  set -- "$@" --apply-migrations
fi

exec "$@"
