#!/usr/bin/env bash
set -Eeuo pipefail

readonly ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly REPORTS="$ROOT/security/reports"

readonly TARGET="${NEXUS_PENTEST_TARGET:-http://127.0.0.1:8000}"
readonly ZAP_TARGET="${NEXUS_ZAP_TARGET:-$TARGET/v1/auth/health}"

readonly SCOPE_MANIFEST="${NEXUS_PENTEST_SCOPE:-$ROOT/security/policy/local.scope.yaml}"
readonly MODE="${1:-probe}"

readonly ZAP_IMAGE="${ZAP_IMAGE:-ghcr.io/zaproxy/zaproxy:2.17.0}"
readonly SCHEMATHESIS_IMAGE="${SCHEMATHESIS_IMAGE:-schemathesis/schemathesis:4.24.3}"

case "$MODE" in
  probe) ;;
  full)
    if [[ "${NEXUS_DISPOSABLE_STACK:-}" != "I_UNDERSTAND_THIS_IS_DISPOSABLE" ]]; then
      echo "refusing full scan: explicit disposable-stack acknowledgement required" >&2
      exit 64
    fi
    ;;
  *)
    echo "usage: $0 {probe|full}" >&2
    exit 64
    ;;
esac

# Vérifie que la cible appartient bien au scope autorisé.
python3 "$ROOT/security/scripts/target_guard.py" \
  "$TARGET" \
  "$SCOPE_MANIFEST" >/dev/null
python3 "$ROOT/security/scripts/target_guard.py" \
  "$ZAP_TARGET" \
  "$SCOPE_MANIFEST" >/dev/null

mkdir -p "$REPORTS"

# Tests de sécurité spécifiques à Nexus :
# - authentification absente
# - JWT invalide
# - CORS
# - request-id
# - fuite d'erreurs
# - méthodes HTTP dangereuses
python3 "$ROOT/security/scripts/api_security_probe.py" \
  "$TARGET" \
  "$REPORTS/api-security-probe.json"

# En mode "probe", on s'arrête ici.
[[ "$MODE" == "full" ]] || exit 0

command -v docker >/dev/null 2>&1 || {
  echo "docker is required" >&2
  exit 1
}

#
# ZAP
#
# ZAP analyse la surface HTTP de Kong.
#
# On utilise une route publique qui retourne HTTP 200 plutôt que "/",
# car Kong n'expose volontairement aucune page à la racine.
#
set +e
docker run --rm --network host \
  -v "$REPORTS:/zap/wrk:rw" \
  "$ZAP_IMAGE" \
  zap-baseline.py \
  -t "$ZAP_TARGET" \
  -m 2 \
  -T 5 \
  -s \
  -J zap-baseline.json \
  -r zap-baseline.html
zap_status=$?
set -e

# zap-baseline.py returns 2 when it produced warnings. Preserve those findings
# for normalization, but only fail immediately for confirmed failures (1) or
# an incomplete/invalid scan (3+).
if (( zap_status == 2 )); then
  echo "ZAP completed with warnings; findings retained for the normalized gate."
elif (( zap_status != 0 )); then
  echo "ZAP failed with exit code $zap_status" >&2
  exit "$zap_status"
fi

#
# Schemathesis
#
# Chaque spécification OpenAPI est fuzzée séparément.
# Cela teste notamment :
# - types invalides
# - paramètres inattendus
# - payloads limites
# - comportements incohérents avec OpenAPI
#
specs=(
  "services/identity/openapi/openapi.yaml|/v1/auth"
  "services/users/openapi/openapi.yaml|/v1/users"
  "services/parties/openapi/openapi.yaml|/v1/parties"
  "services/projects/projects_server/openapi.yaml|/v1/projects"
  "ia/ai-gateway/openapi.yaml|/v1/ai"
)

spec_index=0
for entry in "${specs[@]}"; do
  spec_index=$((spec_index + 1))
  spec="${entry%%|*}"
  base_path="${entry#*|}"

  args=(
    run
    "/repo/$spec"
    --url "$TARGET$base_path"
    --workers 1
    --rate-limit 300/m
    --phases examples,coverage,fuzzing
    --checks not_a_server_error
    --report junit,ndjson
    --report-junit-path "/reports/schemathesis-$spec_index.xml"
    --report-ndjson-path "/reports/schemathesis-$spec_index.ndjson"
  )

  # Permet éventuellement de tester les routes authentifiées.
  if [[ -n "${NEXUS_PENTEST_BEARER_TOKEN:-}" ]]; then
    args+=(
      --header
      "Authorization: Bearer $NEXUS_PENTEST_BEARER_TOKEN"
    )
  fi

  docker run --rm \
    --network host \
    -v "$ROOT:/repo:ro" \
    -v "$REPORTS:/reports:rw" \
    "$SCHEMATHESIS_IMAGE" \
    "${args[@]}"
done
