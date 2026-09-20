#!/usr/bin/env bash
set -Eeuo pipefail

readonly ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly REPORTS="$ROOT/security/reports"
readonly TARGET="${NEXUS_PENTEST_TARGET:-http://127.0.0.1:8000}"
readonly MODE="${1:-probe}"
readonly ZAP_IMAGE="${ZAP_IMAGE:-ghcr.io/zaproxy/zaproxy:2.17.0}"
readonly SCHEMATHESIS_IMAGE="${SCHEMATHESIS_IMAGE:-schemathesis/schemathesis:4.24.3}"

python3 "$ROOT/security/scripts/target_guard.py" "$TARGET" >/dev/null
mkdir -p "$REPORTS"
python3 "$ROOT/security/scripts/api_security_probe.py" \
  "$TARGET" "$REPORTS/api-security-probe.json"

[[ "$MODE" == "full" ]] || exit 0
command -v docker >/dev/null 2>&1 || { echo "docker is required" >&2; exit 1; }

# The active stage is intentionally local and rate-limited. Host networking is
# used so the scanners reach the loopback-only Kong listener on Linux/WSL.
docker run --rm --network host \
  -v "$REPORTS:/zap/wrk:rw" \
  "$ZAP_IMAGE" zap-baseline.py -t "$TARGET" -m 2 -T 5 -s \
  -J zap-baseline.json -r zap-baseline.html

specs=(
  "services/identity/openapi/openapi.yaml|/v1/auth"
  "services/users/openapi/openapi.yaml|/v1/users"
  "services/parties/openapi/openapi.yaml|/v1/parties"
  "services/projects/projects_server/openapi.yaml|/v1/projects"
  "ia/ai-gateway/openapi.yaml|/v1/ai"
)

for entry in "${specs[@]}"; do
  spec="${entry%%|*}"
  base_path="${entry#*|}"
  args=(run "/repo/$spec" --url "$TARGET$base_path" --workers 1 --rate-limit 60/m --phases examples,coverage,fuzzing)
  if [[ -n "${NEXUS_PENTEST_BEARER_TOKEN:-}" ]]; then
    args+=(--header "Authorization: Bearer $NEXUS_PENTEST_BEARER_TOKEN")
  fi
  docker run --rm --network host -v "$ROOT:/repo:ro" \
    "$SCHEMATHESIS_IMAGE" "${args[@]}"
done
