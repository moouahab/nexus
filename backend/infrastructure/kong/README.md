# Kong Gateway

Kong is the local API entrypoint for the current NEXUS backend services.

```text
Client
  -> Kong http://127.0.0.1:8000
  -> identity / users / parties / projects on the internal nexus_gateway Docker network
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

Start the backend services first, then start Kong:

```bash
make gateway-network
make services-up
make gateway-up
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

Kong and the API containers share the external Docker network `nexus_gateway`.
Only Kong is published on the host. Service API containers are not published on
host ports in development; they are reachable by Kong through Docker DNS aliases
such as `identity-api`, `users-api`, `parties-api`, and `projects-api`.
