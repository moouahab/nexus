#!/usr/bin/env bash
set -Eeuo pipefail

# Proves logical backup + restore without touching the source database. Only
# explicitly named test containers and *_test databases are accepted.
readonly container="${1:-}"
readonly database="${2:-}"
readonly report="${3:-security/reports/backup-restore.json}"

if [[ "${NEXUS_DISPOSABLE_DATABASE:-}" != "I_UNDERSTAND_THIS_IS_DISPOSABLE" ]]; then
  echo "refusing: set NEXUS_DISPOSABLE_DATABASE for an explicitly disposable local test DB" >&2
  exit 64
fi
[[ "$container" =~ ^[a-z0-9_-]+postgres_test-[0-9]+$ ]] || { echo "refusing non-test container" >&2; exit 64; }
[[ "$database" =~ ^[a-z0-9_]+_test$ ]] || { echo "refusing non-test database" >&2; exit 64; }
command -v docker >/dev/null || { echo "docker is required" >&2; exit 69; }

restore_db="nexus_restore_verify_${RANDOM}_test"
dump_path="/tmp/nexus-backup-$RANDOM.dump"
started="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
source_manifest="$(mktemp)"
restored_manifest="$(mktemp)"
cleanup() {
  docker exec "$container" dropdb --if-exists --force -U postgres "$restore_db" >/dev/null 2>&1 || true
  docker exec "$container" rm -f "$dump_path" >/dev/null 2>&1 || true
  rm -f "$source_manifest" "$restored_manifest"
}
trap cleanup EXIT

docker inspect "$container" --format '{{.State.Running}}' | grep -qx true
docker exec "$container" pg_dump -U postgres --format=custom --no-owner --no-privileges --file="$dump_path" "$database"
docker exec "$container" createdb -U postgres "$restore_db"
docker exec "$container" pg_restore -U postgres --exit-on-error --no-owner --no-privileges --dbname="$restore_db" "$dump_path"
source_tables="$(docker exec "$container" psql -U postgres -d "$database" -Atqc "select count(*) from pg_catalog.pg_tables where schemaname not in ('pg_catalog','information_schema')")"
restored_tables="$(docker exec "$container" psql -U postgres -d "$restore_db" -Atqc "select count(*) from pg_catalog.pg_tables where schemaname not in ('pg_catalog','information_schema')")"
[[ "$source_tables" == "$restored_tables" ]] || { echo "restore verification failed" >&2; exit 1; }

# Compare an exact row-count manifest for every user table. This proves data,
# not only schema objects, survived the round trip. Identifiers are quoted by
# PostgreSQL before they are reused below.
table_query="select format('%I.%I', schemaname, tablename) from pg_catalog.pg_tables where schemaname not in ('pg_catalog','information_schema') order by 1"
while IFS= read -r table; do
  source_count="$(docker exec "$container" psql -U postgres -d "$database" -Atqc "select count(*) from $table")"
  restored_count="$(docker exec "$container" psql -U postgres -d "$restore_db" -Atqc "select count(*) from $table")"
  printf '%s\t%s\n' "$table" "$source_count" >> "$source_manifest"
  printf '%s\t%s\n' "$table" "$restored_count" >> "$restored_manifest"
done < <(docker exec "$container" psql -U postgres -d "$database" -Atqc "$table_query")
cmp --silent "$source_manifest" "$restored_manifest" || {
  echo "restore verification failed: per-table row counts differ" >&2
  diff -u "$source_manifest" "$restored_manifest" >&2 || true
  exit 1
}
source_rows="$(awk '{ total += $NF } END { print total + 0 }' "$source_manifest")"

mkdir -p "$(dirname "$report")"
printf '{"schemaVersion":1,"tool":"nexus-backup-restore","status":"PASS","container":"%s","database":"%s","sourceTables":%s,"restoredTables":%s,"sourceRows":%s,"timestamp":"%s"}\n' \
  "$container" "$database" "$source_tables" "$restored_tables" "$source_rows" "$started" > "$report"
echo "backup/restore PASS: $database ($source_tables tables, $source_rows rows)"
