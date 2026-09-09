# Kong Gateway

Kong is the local API entrypoint for the current NEXUS backend services.

```text
Client
  -> Kong http://127.0.0.1:8000
  -> identity / users / parties / projects
```

## Routes

| Public path | Upstream |
| --- | --- |
| `/v1/auth/*` | Identity web auth routes on `127.0.0.1:8182/auth/*` |
| `/.well-known/*` | Identity well-known routes on `127.0.0.1:8182/.well-known/*` |
| `/v1/users/*` | Users Serverpod API on `127.0.0.1:8380/*` |
| `/v1/parties/*` | Parties Serverpod API on `127.0.0.1:8480/*` |
| `/v1/projects/*` | Projects Serverpod API on `127.0.0.1:8280/*` |

## Run

Start the backend services first, then start Kong:

```bash
make services-up
make gateway-up
```

Useful checks:

```bash
make gateway-config
make gateway-status
```

The local gateway targets host-published service ports through
`host.docker.internal`. This keeps service compose files independent while the
backend is still evolving.
