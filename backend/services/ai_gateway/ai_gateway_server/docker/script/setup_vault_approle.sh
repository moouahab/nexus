#!/usr/bin/env bash
set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_LIB_DIR="$SCRIPT_DIR/lib"
readonly BACKEND_ROOT="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
readonly SERVICE_RUNTIME_LIB_DIR="$BACKEND_ROOT/infrastructure/service-runtime/script/lib"

source "$SERVICE_RUNTIME_LIB_DIR/common.sh"
source "$SCRIPT_LIB_DIR/paths.sh"
source "$SERVICE_RUNTIME_LIB_DIR/secrets.sh"
source "$SCRIPT_LIB_DIR/secrets.sh"
source "$SERVICE_RUNTIME_LIB_DIR/docker.sh"
source "$SERVICE_RUNTIME_LIB_DIR/vault.sh"
source "$SCRIPT_LIB_DIR/vault.sh"

main() {
  setup_environment
  assert_docker_ready
  prepare_local_secrets
  reset_vault_agent
  start_vault
  wait_for_vault
  vault_login
  write_ai_gateway_runtime_secrets
  configure_ai_gateway_policy
  ensure_approle_auth_enabled
  configure_ai_gateway_approle
  generate_approle_credentials
  start_full_stack
  verify_vault_agent_rendered_files
  sync_postgres_password_from_vault
  print_success_summary
}

main "$@"
