#!/usr/bin/env bash
set -Eeuo pipefail

readonly root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly compose_file="$root/security/fixtures/resilience-stack.yaml"
readonly project="nexus-v0-proof"
readonly reports="$root/security/reports"
readonly postgres_secret="$root/services/projects/projects_server/secrets/postgres_test_password"
readonly redis_secret="$root/services/projects/projects_server/secrets/redis_test_password"
readonly database="projects_test"

[[ "${NEXUS_DISPOSABLE_STACK:-}" == "I_UNDERSTAND_THIS_IS_DISPOSABLE" ]] || {
  echo "refusing: operational proofs require an explicitly disposable stack" >&2
  exit 64
}
[[ -s "$postgres_secret" && -s "$redis_secret" ]] || {
  echo "refusing: disposable PostgreSQL and Redis test secrets are required" >&2
  exit 66
}

mkdir -p "$reports"

compose() {
  docker compose -p "$project" -f "$compose_file" "$@"
}

cleanup() {
  compose down --volumes --remove-orphans >/dev/null 2>&1 || true
}
trap cleanup EXIT

compose up --build --detach

postgres_container="$(compose ps -q postgres_test)"
redis_container="$(compose ps -q redis_test)"
[[ -n "$postgres_container" && -n "$redis_container" ]]

for _ in {1..30}; do
  compose exec -T postgres_test pg_isready -U postgres -d "$database" \
    >/dev/null 2>&1 && break
  sleep 1
done
compose exec -T postgres_test pg_isready -U postgres -d "$database" >/dev/null

for url in http://127.0.0.1:18081 http://127.0.0.1:18082; do
  for _ in {1..30}; do
    curl --fail --silent --max-time 2 "$url" >/dev/null 2>&1 && break
    sleep 1
  done
  curl --fail --silent --max-time 2 "$url" >/dev/null
done

# Seed deterministic evidence so restore proves data as well as schema.
compose exec -T postgres_test psql -U postgres -d "$database" \
  -v ON_ERROR_STOP=1 \
  -c 'create table if not exists v0_proof(id integer primary key, value text not null);' \
  -c "insert into v0_proof(id, value) values (1, 'nexus') on conflict (id) do update set value = excluded.value;" \
  >/dev/null

postgres_name="$(docker inspect --format '{{.Name}}' "$postgres_container" | sed 's#^/##')"
redis_name="$(docker inspect --format '{{.Name}}' "$redis_container" | sed 's#^/##')"

NEXUS_DISPOSABLE_DATABASE=I_UNDERSTAND_THIS_IS_DISPOSABLE \
  "$root/security/scripts/backup_restore_test.sh" \
  "$postgres_name" "$database" "$reports/backup-restore.json"

NEXUS_RESILIENCE_EXECUTE=true NEXUS_DISPOSABLE_PROJECT="$project" \
  "$root/security/scripts/dependency_resilience_test.sh" postgres \
  "$postgres_name" http://127.0.0.1:18081 \
  "$reports/resilience-postgres.json"

NEXUS_RESILIENCE_EXECUTE=true NEXUS_DISPOSABLE_PROJECT="$project" \
  "$root/security/scripts/dependency_resilience_test.sh" redis \
  "$redis_name" http://127.0.0.1:18082 \
  "$reports/resilience-redis.json"

echo "V0 operational proofs PASS"
