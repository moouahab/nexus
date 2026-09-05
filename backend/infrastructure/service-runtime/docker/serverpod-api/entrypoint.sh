#!/bin/sh

set -eu

passwords_source="${SERVERPOD_PASSWORDS_SOURCE:-/run/vault/secrets/serverpod-passwords.yaml}"
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

wait_for_readable_file "$passwords_source" "Configuration Serverpod passwords Vault"
cp "$passwords_source" "$passwords_target"

set -- ./server --mode="$mode" --server-id="$server_id" --logging="$log_level" --role="$server_role"

if [ "$should_apply_migrations" = "true" ]; then
  set -- "$@" --apply-migrations
fi

exec "$@"
