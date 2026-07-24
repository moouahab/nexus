#!/bin/sh

set -eu

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
