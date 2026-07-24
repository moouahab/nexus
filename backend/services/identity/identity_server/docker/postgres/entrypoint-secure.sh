#!/bin/sh

set -eu

config_file="/run/config/postgres.conf"
password_file="/run/secrets/postgres_password"

if [ ! -r "$config_file" ]; then
  echo "Configuration PostgreSQL introuvable." >&2
  exit 1
fi

if [ ! -r "$password_file" ]; then
  echo "Secret PostgreSQL introuvable." >&2
  exit 1
fi

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
