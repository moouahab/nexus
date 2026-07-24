#!/bin/sh

set -eu

config_file="/run/config/postgres.conf"
password_file="${POSTGRES_PASSWORD_FILE:-}"
secret_wait_timeout="${SECRET_WAIT_TIMEOUT_SECONDS:-60}"

if [ -z "$password_file" ]; then
  if [ -e /run/secrets/postgres_password ]; then
    password_file="/run/secrets/postgres_password"
  else
    password_file="/run/vault/secrets/postgres_password"
  fi
fi

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

if [ ! -r "$config_file" ]; then
  echo "Configuration PostgreSQL introuvable." >&2
  exit 1
fi

wait_for_readable_file "$password_file" "Secret PostgreSQL"

# Charge uniquement les paramètres non sensibles.
while IFS='=' read -r key value || [ -n "$key" ]; do
  case "$key" in
    POSTGRES_USER)
      export POSTGRES_USER="$value"
      ;;
    POSTGRES_DB)
      export POSTGRES_DB="$value"
      ;;
  esac
done < "$config_file"

# L'image PostgreSQL lit directement le mot de passe depuis ce fichier.
export POSTGRES_PASSWORD_FILE="$password_file"

exec /usr/local/bin/docker-entrypoint.sh "$@"
