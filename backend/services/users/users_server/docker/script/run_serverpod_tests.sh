#!/usr/bin/env bash
set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly USERS_SERVER_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
readonly BACKEND_ROOT="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
readonly SERVICE_RUNTIME_TEST_RUNNER="$BACKEND_ROOT/infrastructure/service-runtime/script/serverpod/run_tests.sh"
POSTGRES_TEST_PORT="${POSTGRES_TEST_PORT:-9390}"
REDIS_TEST_PORT="${REDIS_TEST_PORT:-9391}"

SERVER_ROOT="$USERS_SERVER_ROOT" \
POSTGRES_TEST_PORT="$POSTGRES_TEST_PORT" \
REDIS_TEST_PORT="$REDIS_TEST_PORT" \
bash "$SERVICE_RUNTIME_TEST_RUNNER" "$@"
