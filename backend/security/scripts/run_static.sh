#!/usr/bin/env bash
set -Eeuo pipefail

readonly ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly REPORTS="$ROOT/security/reports"
readonly GITLEAKS_IMAGE="${GITLEAKS_IMAGE:-ghcr.io/gitleaks/gitleaks:v8.30.1}"
readonly TRIVY_IMAGE="${TRIVY_IMAGE:-ghcr.io/aquasecurity/trivy:0.74.0}"
readonly SEMGREP_IMAGE="${SEMGREP_IMAGE:-semgrep/semgrep:1.136.0}"

command -v docker >/dev/null 2>&1 || { echo "docker is required" >&2; exit 1; }
mkdir -p "$REPORTS"

status=0

docker run --rm \
  -v "$ROOT:/repo:ro" -v "$REPORTS:/reports:rw" \
  "$GITLEAKS_IMAGE" dir /repo --config /repo/security/gitleaks.toml \
  --redact --report-format sarif \
  --report-path /reports/gitleaks.sarif || status=1

docker run --rm \
  -v "$ROOT:/repo:ro" -v "$REPORTS:/reports:rw" \
  "$TRIVY_IMAGE" fs --scanners vuln,secret,misconfig \
  --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 \
  --skip-dirs '**/secrets' --skip-dirs '**/.dart_tool' \
  --format sarif --output /reports/trivy.sarif /repo || status=1

docker run --rm \
  -v "$ROOT:/src:ro" -v "$REPORTS:/reports:rw" \
  "$SEMGREP_IMAGE" semgrep scan --config p/security-audit --config p/secrets \
  --metrics=off --error --no-git-ignore --exclude '**/secrets/**' \
  --exclude '**/.dart_tool/**' --exclude '**/generated/**' \
  --json --json-output=/reports/semgrep.json /src || status=1

echo "security reports: $REPORTS"
exit "$status"
