#!/usr/bin/env bash
set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly IDENTITY_SERVER_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
readonly BACKEND_ROOT="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
readonly SERVICE_RUNTIME_TEST_RUNNER="$BACKEND_ROOT/infrastructure/service-runtime/script/serverpod/run_tests.sh"
POSTGRES_TEST_PORT="${POSTGRES_TEST_PORT:-9190}"
REDIS_TEST_PORT="${REDIS_TEST_PORT:-9191}"

SERVER_ROOT="$IDENTITY_SERVER_ROOT" \
POSTGRES_TEST_PORT="$POSTGRES_TEST_PORT" \
REDIS_TEST_PORT="$REDIS_TEST_PORT" \
SERVERPOD_TEST_AUTH_PASSWORDS=true \
bash "$SERVICE_RUNTIME_TEST_RUNNER" "$@"
