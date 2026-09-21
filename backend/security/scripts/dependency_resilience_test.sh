#!/usr/bin/env bash
set -Eeuo pipefail

# Simulates temporary PostgreSQL or Redis loss by pausing a disposable test
# container. Dry-run is the default; execution requires an exact Compose project.
readonly root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly dependency="${1:-}"
readonly container="${2:-}"
readonly probe_url="${3:-}"
readonly report="${4:-$root/security/reports/resilience-${dependency:-unknown}.json}"
readonly scope="${NEXUS_PENTEST_SCOPE:-$root/security/policy/local.scope.yaml}"
readonly execute="${NEXUS_RESILIENCE_EXECUTE:-false}"
readonly expected_project="${NEXUS_DISPOSABLE_PROJECT:-}"

case "$dependency" in
  postgres) readonly expected_service="postgres_test" ;;
  redis) readonly expected_service="redis_test" ;;
  *) echo "usage: $0 {postgres|redis} <*_test-container> <probe-url> [report.json]" >&2; exit 64 ;;
esac

[[ "$container" =~ ^[a-z0-9_-]+-${expected_service}-[0-9]+$ ]] || {
  echo "refusing container that is not a ${expected_service} Compose container" >&2; exit 64;
}
python3 "$root/security/scripts/target_guard.py" "$probe_url" "$scope" >/dev/null

write_report() {
  local status="$1" phase="$2" outage_observed="$3" timestamp
  timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  mkdir -p "$(dirname "$report")"
  printf '{"schemaVersion":1,"tool":"nexus-resilience","status":"%s","phase":"%s","scenario":"%s-temporary-loss","container":"%s","probeUrl":"%s","outageObserved":%s,"timestamp":"%s"}\n' \
    "$status" "$phase" "$dependency" "$container" "$probe_url" "$outage_observed" "$timestamp" > "$report"
}

if [[ "$execute" != "true" ]]; then
  write_report "DRY_RUN" "planned" "false"
  echo "DRY-RUN: would pause $container, verify loss, unpause it, and verify $probe_url recovery"
  exit 0
fi

[[ "${NEXUS_DISPOSABLE_STACK:-}" == "I_UNDERSTAND_THIS_IS_DISPOSABLE" ]] || {
  echo "refusing: explicit disposable-stack acknowledgement required" >&2; exit 64;
}
[[ -n "$expected_project" ]] || {
  echo "refusing: NEXUS_DISPOSABLE_PROJECT must name the exact Compose project" >&2; exit 64;
}

readonly actual_project="$(docker inspect --format '{{ index .Config.Labels "com.docker.compose.project" }}' "$container")"
readonly actual_service="$(docker inspect --format '{{ index .Config.Labels "com.docker.compose.service" }}' "$container")"
[[ "$actual_project" == "$expected_project" ]] || {
  echo "refusing: container belongs to Compose project '$actual_project', not '$expected_project'" >&2; exit 64;
}
[[ "$actual_service" == "$expected_service" ]] || {
  echo "refusing: container service is '$actual_service', not '$expected_service'" >&2; exit 64;
}

curl --fail --silent --show-error --max-time 3 --max-redirs 0 "$probe_url" >/dev/null || {
  write_report "FAIL" "baseline" "false"; echo "refusing: baseline probe is not healthy" >&2; exit 1;
}

paused=false
restore_dependency() {
  if [[ "$paused" == "true" ]]; then docker unpause "$container" >/dev/null 2>&1 || true; fi
}
trap restore_dependency EXIT INT TERM

docker pause "$container" >/dev/null
paused=true
outage_observed=false
for _ in {1..10}; do
  if ! curl --fail --silent --show-error --max-time 2 --max-redirs 0 "$probe_url" >/dev/null 2>&1; then
    outage_observed=true
    break
  fi
  sleep 1
done
docker unpause "$container" >/dev/null
paused=false

if [[ "$outage_observed" != "true" ]]; then
  write_report "FAIL" "outage" "false"; echo "probe stayed healthy while $dependency was unavailable" >&2; exit 1
fi

for _ in {1..30}; do
  if curl --fail --silent --show-error --max-time 2 --max-redirs 0 "$probe_url" >/dev/null; then
    write_report "PASS" "recovered" "true"
    echo "$dependency temporary-loss resilience PASS: $container"
    exit 0
  fi
  sleep 1
done
write_report "FAIL" "recovery" "true"
echo "service did not recover within 30 seconds" >&2
exit 1
