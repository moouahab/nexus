#!/bin/sh

set -eu

password_file="${REDIS_PASSWORD_FILE:-/run/secrets/redis_password}"

if [ ! -r "$password_file" ]; then
  echo "Erreur : secret Redis introuvable ou illisible." >&2
  exit 1
fi

redis_password="$(tr -d '\r\n' < "$password_file")"

if [ -z "$redis_password" ]; then
  echo "Erreur : le mot de passe Redis est vide." >&2
  exit 1
fi

exec redis-server --requirepass "$redis_password"
