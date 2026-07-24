#!/bin/sh

set -eu

password_file="${REDIS_PASSWORD_FILE:-}"
secret_wait_timeout="${SECRET_WAIT_TIMEOUT_SECONDS:-60}"

if [ -z "$password_file" ]; then
  if [ -e /run/secrets/redis_password ]; then
    password_file="/run/secrets/redis_password"
  else
    password_file="/run/vault/secrets/redis_password"
  fi
fi

elapsed=0
while [ ! -r "$password_file" ]; do
  if [ "$elapsed" -ge "$secret_wait_timeout" ]; then
    echo "Erreur : secret Redis introuvable ou illisible." >&2
    exit 1
  fi

  sleep 1
  elapsed=$((elapsed + 1))
done

redis_password="$(tr -d '\r\n' < "$password_file")"

if [ -z "$redis_password" ]; then
  echo "Erreur : le mot de passe Redis est vide." >&2
  exit 1
fi

exec redis-server --requirepass "$redis_password"
