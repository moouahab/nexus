#!/bin/sh

set -eu

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)"
cd "$root_dir"

command -v docker >/dev/null 2>&1 || {
  echo "docker is required" >&2
  exit 1
}
command -v jq >/dev/null 2>&1 || {
  echo "jq is required" >&2
  exit 1
}

validate_service() {
  service_name="$1"
  service_dir="$2"
  expected_alias="$3"
  expected_network="$4"

  docker compose -f "$service_dir/docker-compose.yaml" config -q
  docker compose \
    -f "$service_dir/docker/compose/resources.yaml" \
    -f "$service_dir/docker/compose/prod.yaml" config -q
  docker compose \
    -f "$service_dir/docker/compose/resources.yaml" \
    -f "$service_dir/docker/compose/test.yaml" \
    --profile test config -q
  docker compose -f "$service_dir/docker-compose.yaml" --profile debug config -q

  rendered="$(docker compose -f "$service_dir/docker-compose.yaml" config --format json)"
  printf '%s\n' "$rendered" | jq -e --arg alias "$expected_alias" --arg network "$expected_network" '
    .services.api
    | .read_only == true
      and (.cap_drop | index("ALL") != null)
      and (.tmpfs | length > 0)
      and (.pids_limit > 0)
      and (.mem_limit > 0)
      and (.networks[$network].aliases | index($alias) != null)
  ' >/dev/null || {
    echo "$service_name API is missing a hardening or gateway invariant" >&2
    exit 1
  }

  printf '%s\n' "$rendered" | jq -e '
    ([.services.postgres.ports, .services.redis.ports] | map(. == null) | all)
  ' >/dev/null || {
    echo "$service_name publishes a database port without the debug profile" >&2
    exit 1
  }
}

validate_service identity services/identity/identity_server identity-api identity_gateway
validate_service users services/users/users_server users-api users_gateway
validate_service parties services/parties/parties_server parties-api parties_gateway
validate_service projects services/projects/projects_server projects-api projects_gateway
validate_service ai-gateway services/ai_gateway/ai_gateway_server ai-gateway-api ai_gateway

docker compose -f infrastructure/kong/docker-compose.yaml config -q
kong_rendered="$(docker compose -f infrastructure/kong/docker-compose.yaml config --format json)"
printf '%s\n' "$kong_rendered" | jq -e '
  .services.kong
  | .read_only == true
    and (.cap_drop | index("ALL") != null)
    and (.tmpfs | length > 0)
    and (.pids_limit > 0)
    and (.mem_limit > 0)
    and .environment.KONG_ADMIN_LISTEN == "off"
' >/dev/null || {
  echo "Kong is missing a hardening invariant or its Admin API is enabled" >&2
  exit 1
}

infrastructure/kong/script/assemble-config.sh --check
echo "Infrastructure configuration is valid."
