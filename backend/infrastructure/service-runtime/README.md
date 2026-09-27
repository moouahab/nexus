# Service Runtime

Reusable runtime building blocks for backend services.

Current shared pieces:

```text
docker/postgres/
docker/redis/
docker/serverpod-api/
docker/vault-agent/
script/lib/common.sh
script/lib/docker.sh
script/lib/secrets.sh
script/lib/vault.sh
script/serverpod/run_tests.sh
vault/agent.hcl
vault/agent-production.hcl
vault/dev-listen-address
vault/production-vault-address
vault/tls/production-ca.crt
```

`script/serverpod/run_tests.sh` supports service-specific test needs through
environment flags. `identity` enables `SERVERPOD_TEST_AUTH_PASSWORDS=true`
because it owns Serverpod auth secrets.

See:

- `docs/serverpod-service-runtime.md` for the runtime convention;
- `docs/vault-operations.md` for shared Vault operational rules.

## Ownership Rule

This directory owns mechanics only:

- shared images;
- shared entrypoints;
- shared shell helpers;
- shared Vault Agent connection config.

Services still own their operational identity:

- service name;
- database name and volume;
- ports;
- Vault secret path and policy;
- declared secrets;
- service-specific Vault templates.

Do not move service secrets here. Each service keeps its own `secrets/` and
`secrets_example/` directories.

Current Serverpod consumers:

- `services/identity/identity_server`
- `services/parties/parties_server`
- `services/projects/projects_server`
- `services/users/users_server`

## Drift validation

Run `bash infrastructure/service-runtime/script/validate_service_runtime.sh` to
detect wrappers which stopped consuming the shared runtime or reintroduced a
generic primitive. Identity still owns its RSA/OAuth preparation and its larger
Vault payload. AI Gateway currently owns Compose configuration only and does not
duplicate the local Vault bootstrap scripts.

Service files remain the intentional extension points for secret names,
business defaults, test ports and Vault payload fields.
