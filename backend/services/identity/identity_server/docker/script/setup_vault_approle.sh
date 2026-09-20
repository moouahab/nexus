#!/usr/bin/env bash
set -Eeuo pipefail

# Initialise local Vault, configure AppRole for the Identity service, generate
# Vault Agent credentials, store runtime secrets, then start the Docker stack.
#
# Usage from identity_server/:
#   ./docker/script/setup_vault_approle.sh
#
# Usage from any directory:
#   /path/to/identity_server/docker/script/setup_vault_approle.sh

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_LIB_DIR="$SCRIPT_DIR/lib"
readonly BACKEND_ROOT="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
readonly SERVICE_RUNTIME_LIB_DIR="$BACKEND_ROOT/infrastructure/service-runtime/script/lib"

source "$SERVICE_RUNTIME_LIB_DIR/common.sh"
source "$SCRIPT_LIB_DIR/paths.sh"
source "$SCRIPT_LIB_DIR/secrets.sh"
source "$SERVICE_RUNTIME_LIB_DIR/secrets.sh"
source "$SERVICE_RUNTIME_LIB_DIR/docker.sh"
source "$SCRIPT_LIB_DIR/vault.sh"
source "$SERVICE_RUNTIME_LIB_DIR/vault.sh"

main() {
  setup_environment
  assert_docker_ready
  prepare_local_secrets
  reset_vault_agent

  start_vault
  wait_for_vault

  vault_login
  write_identity_runtime_secrets
  configure_identity_policy
  ensure_approle_auth_enabled
  configure_identity_approle
  generate_approle_credentials

  start_full_stack
  verify_vault_agent_rendered_files
  sync_postgres_password_from_vault
  print_success_summary
}

main "$@"
