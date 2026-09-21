#!/usr/bin/env bash
set -Eeuo pipefail

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
identity="$root_dir/services/identity/identity_server"
projects="$root_dir/services/projects/projects_server"
key='project_authorization_grant_secret'
password_key='projectAuthorizationGrantSecret'

for script in \
  "$identity/docker/script/lib/paths.sh" \
  "$identity/docker/script/lib/secrets.sh" \
  "$identity/docker/script/lib/vault.sh" \
  "$projects/docker/script/lib/paths.sh" \
  "$projects/docker/script/lib/secrets.sh" \
  "$projects/docker/script/lib/vault.sh"; do
  bash -n "$script"
done

grep -Fq 'services/identity/identity_server/secrets/project_authorization_grant_secret' \
  "$projects/docker/script/lib/paths.sh"
grep -Fq "ensure_secret_file \"\$PROJECT_AUTHORIZATION_GRANT_SECRET_FILE\"" \
  "$identity/docker/script/lib/secrets.sh"
if grep -Fq "ensure_secret_file \"\$PROJECT_AUTHORIZATION_GRANT_SECRET_FILE\"" \
  "$projects/docker/script/lib/secrets.sh"; then
  echo 'Projects must not generate its own project authorization grant secret' >&2
  exit 1
fi

for service in "$identity" "$projects"; do
  grep -Fq "$key=\"\$(cat \"\$PROJECT_AUTHORIZATION_GRANT_SECRET_FILE\")\"" \
    "$service/docker/script/lib/vault.sh"
  grep -Fq "$password_key: '{{ .Data.data.$key }}'" \
    "$service/docker/vault/templates/serverpod-passwords.yaml.ctmpl"
  grep -Fq "$password_key: '{{ .Data.data.$key }}'" \
    "$service/docker/vault/templates/production/serverpod-passwords.yaml.ctmpl"
done

echo 'Project authorization grant secret wiring is valid.'
