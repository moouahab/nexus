#!/usr/bin/env bash
set -Eeuo pipefail

readonly RUNTIME_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly BACKEND_ROOT="$(cd -- "$RUNTIME_ROOT/../.." && pwd)"

fail() {
  printf '[ERROR] %s\n' "$*" >&2
  exit 1
}

for service in identity users parties projects; do
  setup="$BACKEND_ROOT/services/$service/${service}_server/docker/script/setup_vault_approle.sh"
  [[ -f "$setup" ]] || fail "Missing Vault setup wrapper: $setup"
  grep -q 'SERVICE_RUNTIME_LIB_DIR/secrets.sh' "$setup" ||
    fail "$service does not source shared secret primitives"
  grep -q 'SERVICE_RUNTIME_LIB_DIR/vault.sh' "$setup" ||
    fail "$service does not source shared Vault primitives"
done

# These three services use only a service-owned payload plus generic mechanics.
# Identity intentionally retains RSA/OAuth-specific helpers during its migration.
for service in users parties projects; do
  lib_root="$BACKEND_ROOT/services/$service/${service}_server/docker/script/lib"
  if grep -Eq '^(wait_for_vault|vault_login|ensure_approle_auth_enabled|generate_approle_credentials|copy_examples_if_needed|ensure_secret_file|ensure_config_file)\(\)' \
    "$lib_root/secrets.sh" "$lib_root/vault.sh"; then
    fail "$service redefines a shared service-runtime primitive"
  fi
done

printf '[OK] Shared service-runtime boundaries are consistent.\n'
