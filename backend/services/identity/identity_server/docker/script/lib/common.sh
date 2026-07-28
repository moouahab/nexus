#!/usr/bin/env bash

info() {
  printf '\033[1;34m[INFO]\033[0m %s\n' "$*"
}

success() {
  printf '\033[1;32m[OK]\033[0m %s\n' "$*"
}

warning() {
  printf '\033[1;33m[WARN]\033[0m %s\n' "$*" >&2
}

error() {
  printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2
}

cleanup_on_error() {
  local exit_code=$?
  error "Failure near line ${BASH_LINENO[0]} with exit code ${exit_code}."
  exit "$exit_code"
}

trap cleanup_on_error ERR

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "Required command not found: $1"
    exit 1
  fi
}

require_file() {
  if [[ ! -s "$1" ]]; then
    error "Missing or empty file: $1"
    exit 1
  fi
}

random_secret() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -base64 48 | tr -d '\n'
    return 0
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import secrets; print(secrets.token_urlsafe(48), end="")'
    return 0
  fi

  date +%s%N | sha256sum | awk '{print $1}'
}
