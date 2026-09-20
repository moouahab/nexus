#!/usr/bin/env bash

# Shared filesystem primitives for service-owned secret manifests. Services keep
# deciding which secrets exist, which are required and which defaults are safe.

copy_examples_if_needed() {
  if [[ -d "$SECRETS_DIR" ]]; then
    info "secrets/ already exists: it will not be overwritten."
    return 0
  fi

  if [[ -d "$SECRETS_EXAMPLE_DIR" ]]; then
    info "Creating secrets/ from secrets_example/..."
    cp -R "$SECRETS_EXAMPLE_DIR" "$SECRETS_DIR"
    success "secrets/ created."
    return 0
  fi

  info "Creating empty secrets/ directory..."
  mkdir -p "$SECRETS_DIR"
  success "secrets/ created."
}

ensure_secret_file() {
  local path="$1"
  local label="$2"
  local value="${3:-}"

  if [[ -s "$path" ]]; then
    info "$label already exists."
    chmod 600 "$path"
    return 0
  fi

  if [[ -n "$value" ]]; then
    printf '%s' "$value" > "$path"
  else
    random_secret > "$path"
  fi

  chmod 600 "$path"
  success "$label created."
}

ensure_config_file() {
  local path="$1"
  local label="$2"
  local value="${3:-}"

  if [[ -e "$path" ]]; then
    info "$label already exists."
    chmod 600 "$path"
    return 0
  fi

  printf '%s' "$value" > "$path"
  chmod 600 "$path"
  success "$label created."
}

require_optional_config_file() {
  local path="$1"

  if [[ ! -f "$path" ]]; then
    error "Missing config file: $path"
    exit 1
  fi
}
