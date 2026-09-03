#!/bin/sh

set -eu

prepare_approle_secret() {
  source_path="$1"
  destination_path="$2"

  if [ ! -r "$source_path" ]; then
    echo "Vault AppRole secret is not readable: $source_path" >&2
    exit 1
  fi

  rm -f "$destination_path"
  cp "$source_path" "$destination_path"
  if [ "$(id -u)" = "0" ]; then
    chown vault:vault "$destination_path"
  fi
  chmod 0400 "$destination_path"
}

if [ "$(id -u)" = "0" ]; then
  mkdir -p /vault/runtime
  prepare_approle_secret /run/secrets/role_id /vault/runtime/role_id
  prepare_approle_secret /run/secrets/secret_id /vault/runtime/secret_id
  chown vault:vault /vault/runtime

  exec su-exec vault "$0" "$@"
fi

if [ -r /vault/config/agent.hcl.template ]; then
  vault_address="$(tr -d '\r\n' < /vault/config/vault-address)"

  if [ -z "$vault_address" ]; then
    echo "Vault production address is empty." >&2
    exit 1
  fi

  mkdir -p /vault/runtime
  awk -v vault_address="$vault_address" '
    {
      gsub(/__VAULT_ADDRESS__/, vault_address)
      print
    }
  ' /vault/config/agent.hcl.template > /vault/runtime/agent.hcl

  set -- agent -config=/vault/runtime/agent.hcl
fi

exec vault "$@"
