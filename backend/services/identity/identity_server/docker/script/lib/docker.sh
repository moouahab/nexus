#!/usr/bin/env bash

assert_docker_ready() {
  require_command docker

  if ! docker compose version >/dev/null 2>&1; then
    error "Docker Compose v2 is not available."
    exit 1
  fi
}

start_vault() {
  info "Starting Vault service..."
  docker compose up --build --detach vault
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

  for _ in {1..20}; do
    if docker compose exec -T vault_agent sh -c \
      'test -s /vault/secrets/postgres_password &&
       test -s /vault/secrets/redis_password &&
       test -s /vault/secrets/serverpod-passwords.yaml' >/dev/null 2>&1; then
      vault_agent_ready=true
      break
    fi

    sleep 2
  done

  if [[ "$vault_agent_ready" == "true" ]]; then
    docker compose exec -T vault_agent ls -l /vault/secrets
    success "Vault Agent rendered all expected files."
    return 0
  fi

  warning "Vault Agent has not rendered all expected files yet."
  warning "Check logs with: docker compose logs vault_agent"
  docker compose exec -T vault_agent ls -la /vault/secrets 2>/dev/null || true
  exit 1
}
