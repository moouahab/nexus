#!/bin/sh

set -eu

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
target="$root_dir/kong.yaml"
temporary="$(mktemp)"
trap 'rm -f "$temporary"' EXIT HUP INT TERM

{
  cat "$root_dir/config/header.yaml"
  printf '\nservices:\n'
  for fragment in \
    identity.yaml \
    users.yaml \
    parties.yaml \
    projects.yaml \
    ai-gateway.yaml
  do
    cat "$root_dir/config/services/$fragment"
    printf '\n'
  done
  printf 'plugins:\n'
  cat "$root_dir/config/plugins/observability.yaml"
  for fragment in cors.yaml rate-limits.yaml
  do
    printf '\n'
    cat "$root_dir/config/plugins/$fragment"
  done
} > "$temporary"

if [ "${1:-}" = "--check" ]; then
  if ! cmp -s "$temporary" "$target"; then
    echo "kong.yaml is out of date; run infrastructure/kong/script/assemble-config.sh" >&2
    exit 1
  fi
  exit 0
fi

mv "$temporary" "$target"
trap - EXIT HUP INT TERM
