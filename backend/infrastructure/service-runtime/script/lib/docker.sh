#!/usr/bin/env bash

assert_docker_ready() {
  require_command docker

  if ! docker compose version >/dev/null 2>&1; then
    error "Docker Compose v2 is not available."
    exit 1
  fi

  ensure_nexus_gateway_network
}

ensure_nexus_gateway_network() {
  local network_name="${NEXUS_GATEWAY_NETWORK:-nexus_gateway}"

  if docker network inspect "$network_name" >/dev/null 2>&1; then
    return 0
  fi

  info "Creating Docker network: $network_name"
  docker network create "$network_name" >/dev/null
  success "Docker network is ready: $network_name"
}

start_vault() {
  info "Starting Vault service..."
  docker compose up --build --detach vault
}

reset_vault_agent() {
  info "Resetting Vault Agent and its generated runtime files..."

  docker compose stop vault_agent >/dev/null 2>&1 || true
  docker compose rm --force vault_agent >/dev/null 2>&1 || true
  docker compose build vault_agent >/dev/null
  docker compose run --rm --no-deps --entrypoint sh vault_agent -ec '
    rm -f /vault/token/agent-token
    rm -f /vault/secrets/api/serverpod-passwords.yaml
    rm -f /vault/secrets/postgres/postgres_password
    rm -f /vault/secrets/redis/redis_password
  ' >/dev/null

  success "Vault Agent runtime state is clean."
}

start_full_stack() {
  info "Starting the full Docker stack..."
  docker compose up --build --detach
  success "Docker stack started."
}

sync_postgres_password_from_vault() {
  info "Synchronizing PostgreSQL role password with Vault-rendered secret..."

  docker compose exec -T postgres sh -lc '
    pw="$(cat /run/vault/secrets/postgres_password)"
    psql -U postgres -d postgres -v ON_ERROR_STOP=1 -v pw="$pw" <<'"'"'SQL'"'"' >/dev/null
ALTER USER postgres WITH PASSWORD :'"'"'pw'"'"';
SQL
  '

  docker compose restart api >/dev/null
  success "PostgreSQL password synchronized and API restarted."
}

verify_vault_agent_rendered_files() {
  info "Checking files rendered by Vault Agent..."

  local vault_agent_ready=false
  local required_files='test -s /vault/secrets/postgres/postgres_password && test -s /vault/secrets/api/serverpod-passwords.yaml'
  if [[ "${VAULT_AGENT_REQUIRES_REDIS:-true}" == "true" ]]; then
    required_files+=' && test -s /vault/secrets/redis/redis_password'
  fi

  for _ in {1..20}; do
    if docker compose exec -T vault_agent sh -c "$required_files" >/dev/null 2>&1; then
      vault_agent_ready=true
      break
    fi

    sleep 2
  done

  if [[ "$vault_agent_ready" == "true" ]]; then
    docker compose exec -T vault_agent sh -c \
      'ls -l /vault/secrets/api /vault/secrets/postgres /vault/secrets/redis 2>/dev/null || true'
    success "Vault Agent rendered all expected files."
    return 0
  fi

  warning "Vault Agent has not rendered all expected files yet."
  warning "Check logs with: docker compose logs vault_agent"
  docker compose exec -T vault_agent sh -c \
    'ls -la /vault/secrets/api /vault/secrets/postgres /vault/secrets/redis' 2>/dev/null || true
  exit 1
}
