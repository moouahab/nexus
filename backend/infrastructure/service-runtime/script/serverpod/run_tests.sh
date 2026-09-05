#!/usr/bin/env bash
set -Eeuo pipefail

if [[ -z "${SERVER_ROOT:-}" ]]; then
  echo "SERVER_ROOT is required." >&2
  exit 1
fi

POSTGRES_TEST_PORT="${POSTGRES_TEST_PORT:-9290}"
REDIS_TEST_PORT="${REDIS_TEST_PORT:-9291}"

cd "$SERVER_ROOT"

if [[ ! -s secrets/postgres_test_password ]]; then
  echo "Missing secrets/postgres_test_password" >&2
  exit 1
fi

if [[ ! -s secrets/redis_test_password ]]; then
  echo "Missing secrets/redis_test_password" >&2
  exit 1
fi

POSTGRES_TEST_PORT="$POSTGRES_TEST_PORT" \
REDIS_TEST_PORT="$REDIS_TEST_PORT" \
docker compose --profile test up --build --wait postgres_test redis_test

export SERVERPOD_DATABASE_PORT="$POSTGRES_TEST_PORT"
export SERVERPOD_REDIS_ENABLED=true
export SERVERPOD_REDIS_PORT="$REDIS_TEST_PORT"
export SERVERPOD_PASSWORD_database
export SERVERPOD_PASSWORD_redis

if [[ "${SERVERPOD_TEST_AUTH_PASSWORDS:-false}" == "true" ]]; then
  export SERVERPOD_PASSWORD_emailSecretHashPepper="${SERVERPOD_PASSWORD_emailSecretHashPepper:-test-email-secret-pepper}"
  export SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey="${SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey:-test-jwt-secret}"
  export SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper="${SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper:-test-refresh-pepper}"
fi

SERVERPOD_PASSWORD_database="$(
  cat secrets/postgres_test_password
)"
SERVERPOD_PASSWORD_redis="$(
  cat secrets/redis_test_password
)"

dart test "$@"
