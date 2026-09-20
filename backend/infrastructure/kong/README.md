# Kong Gateway

Kong is the local API entrypoint for the current NEXUS backend services.

```text
Client
  -> Kong http://127.0.0.1:8000
  -> one private Docker network per upstream API
```

## Routes

| Public path | Upstream |
| --- | --- |
| `/v1/auth/*` | Identity web auth routes on `identity-api:8082/auth/*` |
| `/.well-known/*` | Identity well-known routes on `identity-api:8082/.well-known/*` |
| `/v1/users/*` | Users REST API on `users-api:8082/*` |
| `/v1/parties/*` | Parties REST API on `parties-api:8082/*` |
| `/v1/projects/*` | Projects REST API on `projects-api:8082/*` |
| `/v1/ai/*` | AI Gateway REST API on `ai-gateway-api:8082/*` |

Compatibility routes ending in `/user`, `/party`, or `/project` continue to
target the Serverpod RPC port `8080` for existing Dart/Flutter clients. New
platform-neutral integrations should use the documented REST resources.

## Run

Start the whole backend through the global orchestration commands:

```bash
make up          # initialize local Vault secrets and start everything
make stack-up    # subsequent start using the existing secrets
make stack-ps
make stack-down
```

Useful checks:

```bash
make gateway-config
make gateway-status
```

The declarative configuration is split under `config/services/` and
`config/plugins/`. `script/assemble-config.sh` generates `kong.yaml` in a
stable order. `make gateway-config` also fails when the generated file is out
of date.

The Kong Admin API is disabled. The status endpoint is bound to localhost and
is intended for health monitoring only.

Kong joins one external private network per API (`nexus_identity_gateway`,
`nexus_users_gateway`, `nexus_parties_gateway`, `nexus_projects_gateway`, and
`nexus_ai_gateway`). An API therefore cannot discover every other API through a
single flat gateway network. The AI Gateway additionally joins the Projects
network because it has an explicit Projects API dependency.

Only Kong is published on the host during a normal start. Service APIs,
PostgreSQL, and Redis remain private. To temporarily expose database ports on
localhost through hardened TCP relay containers, run:

```bash
make stack-debug-up
```

The relays belong to the Compose `debug` profile and disappear with
`make stack-down`. They never listen on a non-loopback host address.
