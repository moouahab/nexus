#!/usr/bin/env bash
set -Eeuo pipefail

readonly root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly server="$root/services/ai_gateway/ai_gateway_server"
readonly report="${1:-$root/security/reports/ai-restart.json}"

"$server/docker/script/run_serverpod_tests.sh" \
  test/ai/reasoning_persistence_database_test.dart \
  --name 'startup recovery recreates one missing durable call'

mkdir -p "$(dirname "$report")"
printf '{"schemaVersion":1,"tool":"nexus-ai-recovery","status":"PASS","scenario":"durable-job-startup-recovery","timestamp":"%s"}\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$report"
echo "AI durable job recovery PASS"
