#!/usr/bin/env bash
set -Eeuo pipefail

# Controlled restart smoke test. Dry-run is the default and only test
# containers are eligible. It never stops a database or deletes data.
readonly root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly container="${1:-}"
readonly health_url="${2:-}"
readonly report="${3:-$root/security/reports/resilience.json}"
readonly scope="${NEXUS_PENTEST_SCOPE:-$root/security/policy/local.scope.yaml}"
readonly execute="${NEXUS_RESILIENCE_EXECUTE:-false}"

[[ "$container" =~ ^[a-z0-9_-]+api_test-[0-9]+$ ]] || { echo "refusing non-test API container" >&2; exit 64; }
python3 "$root/security/scripts/target_guard.py" "$health_url" "$scope" >/dev/null
if [[ "$execute" != "true" ]]; then
  echo "DRY-RUN: would restart $container and verify $health_url"
  exit 0
fi
[[ "${NEXUS_DISPOSABLE_STACK:-}" == "I_UNDERSTAND_THIS_IS_DISPOSABLE" ]] || {
  echo "refusing: explicit disposable-stack acknowledgement required" >&2; exit 64;
}

docker restart --time 10 "$container" >/dev/null
started="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
for _ in {1..30}; do
  if curl --fail --silent --show-error --max-time 2 --max-redirs 0 "$health_url" >/dev/null; then
    mkdir -p "$(dirname "$report")"
    printf '{"schemaVersion":1,"tool":"nexus-resilience","status":"PASS","scenario":"api-restart","container":"%s","healthUrl":"%s","timestamp":"%s"}\n' \
      "$container" "$health_url" "$started" > "$report"
    echo "resilience restart PASS: $container"
    exit 0
  fi
  sleep 1
done
echo "service did not recover within 30 seconds" >&2
exit 1
