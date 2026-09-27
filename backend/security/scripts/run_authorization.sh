#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

cd "$ROOT_DIR"

run_evidence_suite() {
  local label="$1"
  local target="$2"
  printf '\n[authorization evidence] %s\n' "$label"
  make "$target"
}

# The summary below is emitted only after every evidence-bearing suite exits
# successfully. Keep every claim tied to an assertion in one of these suites.
run_evidence_suite 'JWT, scopes and service-token audiences' test-auth
run_evidence_suite 'Users tenant references and REST/RPC parity' test-users
run_evidence_suite 'Parties membership authorization and REST/RPC parity' test-parties
run_evidence_suite 'Projects cross-tenant/BOLA and REST/RPC parity' test-projects
run_evidence_suite 'AI run cross-tenant read/cancel authorization' test-ai-gateway

printf '\nMULTI-TENANT SECURITY\n\n'
printf '%-38s %s\n' 'User A -> Tenant A project creation' 'PASS'
printf '%-38s %s\n' 'User A -> Tenant B project creation' 'DENIED'
printf '%-38s %s\n' 'User A -> Profile B' 'DENIED'
printf '%-38s %s\n' 'User A -> primaryPartyId Tenant B' 'DENIED'
printf '%-38s %s\n' 'User A -> Party B' 'DENIED'
printf '%-38s %s\n' 'User A -> Project B read/mutations' 'DENIED'
printf '%-38s %s\n' 'User A -> Project B child resources' 'DENIED'
printf '%-38s %s\n' 'User A -> AiRun B read/cancel' 'DENIED'
printf '%-38s %s\n' 'Forbidden vs missing resource' 'INDISTINGUISHABLE'
printf '%-38s %s\n' 'ServiceToken(projects.read) -> write' 'DENIED'
printf '%-38s %s\n' 'ServiceToken(projects.write) -> read' 'DENIED'
printf '%-38s %s\n' 'Cross-service token audience' 'DENIED'
printf '%-38s %s\n' 'JWT expiry / issuer / scopes' 'PASS'
printf '%-38s %s\n' 'Users REST / RPC parity' 'PASS'
printf '%-38s %s\n' 'Parties REST / RPC parity' 'PASS'
printf '%-38s %s\n' 'Projects REST / RPC parity' 'PASS'
