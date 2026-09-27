#!/usr/bin/env bash
set -Eeuo pipefail

readonly script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly server_root="$(cd -- "$script_dir/../.." && pwd)"
readonly backend_root="$(cd -- "$script_dir/../../../../.." && pwd)"

SERVER_ROOT="$server_root" \
POSTGRES_TEST_PORT="${POSTGRES_TEST_PORT:-9590}" \
REDIS_TEST_PORT="${REDIS_TEST_PORT:-9591}" \
SERVERPOD_TEST_REDIS_ENABLED=false \
AI_GATEWAY_RUN_DATABASE_TESTS=true \
bash "$backend_root/infrastructure/service-runtime/script/serverpod/run_tests.sh" "$@"
