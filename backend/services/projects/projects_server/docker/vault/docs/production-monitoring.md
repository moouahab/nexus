# Production Monitoring

This document lists the minimum checks and alerts for the production Vault Agent
setup.

## What To Monitor

Monitor these conditions:

- `vault_agent` is unhealthy
- `/vault/secrets/serverpod-passwords.yaml` is missing or empty
- Vault Agent AppRole authentication fails
- Vault Agent template rendering fails
- Vault Agent token cannot renew
- API startup fails because secrets are missing
- production Vault is unreachable

## Local Diagnostic Commands

Use these commands during manual investigation:

```bash
docker compose -f docker/compose/prod.yaml ps
docker compose -f docker/compose/prod.yaml logs --no-color --tail=100 vault_agent
docker compose -f docker/compose/prod.yaml logs --no-color --tail=100 api
docker compose -f docker/compose/prod.yaml exec vault_agent ls -l /vault/secrets
```

Check the token sink:

```bash
docker compose -f docker/compose/prod.yaml exec vault_agent test -s /vault/token/agent-token
```

Check the rendered Serverpod passwords file:

```bash
docker compose -f docker/compose/prod.yaml exec vault_agent test -s /vault/secrets/serverpod-passwords.yaml
```

## Alert Rules

Create alerts for:

- `vault_agent` container unhealthy for more than 1 minute
- `api` container unhealthy for more than 1 minute
- `vault_agent` logs contain `authentication failed`
- `vault_agent` logs contain `permission denied`
- `vault_agent` logs contain `template`
- `vault_agent` logs contain `renew`
- `vault_agent` logs contain `connection refused`
- `vault_agent` logs contain TLS or certificate errors

## File Checks

The Vault Agent healthcheck currently requires:

```text
/vault/token/agent-token
/vault/secrets/postgres_password
/vault/secrets/redis_password
/vault/secrets/serverpod-passwords.yaml
```

If any of these files is missing or empty, dependent services should not start.

## Vault Availability

Vault Agent can keep using a valid token during short Vault outages, but new
auth, renewal, and template refresh can fail while Vault is unavailable.

Alert if Vault is unreachable from the deployment network.

Useful symptoms:

```text
connection refused
timeout
certificate verify failed
permission denied
```

## Operational Response

When `vault_agent` is unhealthy:

1. Check `docker compose ps`.
2. Read `vault_agent` logs.
3. Confirm AppRole files are mounted.
4. Confirm Vault address and CA certificate are correct.
5. Confirm Vault policy can read the production secret path.
6. Restart `vault_agent` only after the root cause is understood.

When the API is unhealthy:

1. Confirm `vault_agent` is healthy.
2. Confirm `/vault/secrets/serverpod-passwords.yaml` exists.
3. Read API startup logs.
4. Confirm DB and Redis credentials match the real services.
5. Restart API after correcting credentials or connectivity.

## Minimum Production Dashboard

Track:

- container state for `api`
- container state for `vault_agent`
- last restart time for `vault_agent`
- last restart time for `api`
- Vault Agent log error count
- API startup error count
- Vault reachability from the deployment environment

The local commands above should become production alerts in the deployment
platform.
