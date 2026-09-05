# Inject AppRole Secrets

This document explains how production should provide Vault AppRole credentials
to `vault_agent`.

## Required Files

Vault Agent expects two files:

```text
/run/secrets/role_id
/run/secrets/secret_id
```

In `docker/compose/prod.yaml`, those files come from:

```yaml
secrets:
  vault_production_role_id:
    file: ../../secrets/production/vault_role_id

  vault_production_secret_id:
    file: ../../secrets/production/vault_secret_id
```

This file-based setup is useful for local validation of the production Compose
shape. In real production, do not copy these values by hand to a server.

## What Not To Do

Do not commit:

```text
secrets/production/vault_role_id
secrets/production/vault_secret_id
```

Do not pass AppRole credentials through:

```yaml
environment:
```

Do not reuse the same `secret_id` across many deployments when
`secret_id_num_uses=1` is intended.

## Recommended Production Sources

Use the deployment platform secret store:

- Docker Swarm secrets
- Kubernetes Secrets
- External Secrets Operator
- CI/CD secret store
- cloud secret manager used only for Vault Agent bootstrap

The deployment platform should mount the secrets into the container as files,
not inject them as environment variables.

## Docker Compose Local Validation

For local validation only:

```bash
mkdir -p secrets/production

vault read -field=role_id \
  auth/approle/role/projects-production/role-id \
  > secrets/production/vault_role_id

vault write -field=secret_id -f \
  auth/approle/role/projects-production/secret-id \
  > secrets/production/vault_secret_id
```

Then validate the Compose shape:

```bash
docker compose -f docker/compose/prod.yaml config
```

## Kubernetes Pattern

Create a Kubernetes Secret from secure CI/CD or an external secret operator:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: projects-vault-approle
type: Opaque
stringData:
  role_id: "<role-id>"
  secret_id: "<secret-id>"
```

Mount it as files:

```yaml
volumeMounts:
  - name: vault-approle
    mountPath: /run/secrets
    readOnly: true

volumes:
  - name: vault-approle
    secret:
      secretName: projects-vault-approle
```

Expected paths inside the container:

```text
/run/secrets/role_id
/run/secrets/secret_id
```

## Rotation-Aware Deployment

With this AppRole configuration:

```text
secret_id_num_uses=1
secret_id_ttl=24h
```

each deployment should receive a fresh `secret_id`.

Deployment flow:

1. Generate a new `secret_id`.
2. Store it in the deployment platform secret store.
3. Deploy or restart `vault_agent`.
4. Verify `vault_agent` is healthy.
5. Verify rendered files exist.

Validation:

```bash
docker compose -f docker/compose/prod.yaml ps
docker compose -f docker/compose/prod.yaml logs --no-color --tail=120 vault_agent
```

## Failure Modes

If `role_id` is missing:

```text
Vault Agent cannot start AppRole auth.
```

If `secret_id` is missing or expired:

```text
Vault Agent authentication fails.
```

If the policy is wrong:

```text
Vault Agent authenticates but cannot render templates.
```

If the secret path is wrong:

```text
Vault Agent template rendering fails.
```

Use:

```bash
docker compose -f docker/compose/prod.yaml logs --no-color --tail=120 vault_agent
```

to distinguish these cases.
