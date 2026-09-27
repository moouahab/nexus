# NEXUS local observability (ELK)

This optional stack tails Docker's `json-file` logs and provides a prebuilt
Kibana workspace for local diagnosis. It is independent from the application
Compose projects: stopping ELK never stops an API.

## Start

Linux must allow Elasticsearch to create enough memory maps:

```sh
sudo sysctl -w vm.max_map_count=262144
docker compose -f infrastructure/observability/docker-compose.yaml up -d
```

Open <http://localhost:5601/app/dashboards#/view/nexus-operations>. The setup
job creates the `nexus-logs-*` data view, the **NEXUS — Vue opérationnelle**
dashboard, its searches, and a seven-day retention policy. It is safe to run
the setup job again:

```sh
docker compose -f infrastructure/observability/docker-compose.yaml run --rm kibana-setup
```

Distributed traces are exported by the APIs over OTLP/HTTP to the local
OpenTelemetry Collector and forwarded to Jaeger. Open the Jaeger UI at
<http://localhost:16686>, select a NEXUS service, then search for traces.
The collector exposes OTLP/gRPC on `127.0.0.1:4317`, OTLP/HTTP on
`127.0.0.1:4318`, and its health endpoint on `127.0.0.1:13133`.

The API containers use `http://otel-collector:4318` on the isolated
`nexus_telemetry` network. W3C `traceparent` and `baggage` headers are
propagated on service-to-service HTTP calls. Set `OTEL_SDK_DISABLED=true` to
disable export, or override `OTEL_EXPORTER_OTLP_ENDPOINT` for another backend.

All published observability ports are bound to loopback. The Collector and
Jaeger join only the observability and telemetry networks; neither joins a
service database or gateway network.

## What the dashboard contains

- HTTP requests with service, method, status, latency, and request ID;
- 4xx/5xx responses;
- requests slower than 500 ms;
- AI outcomes, queue wait, execution duration, and reasoning level;
- raw service logs for incident searches.

Useful KQL filters include:

```text
service.name: identity
http.request.id: "local-check-1234"
http.response.status_code >= 500
event.action: ai_run_processed and event.outcome: failed
```

The application JSON schema is mapped to stable fields (`service.name`,
`event.action`, `http.*`, `event.duration_ms`, and `ai.*`). Non-JSON container
output remains searchable in `event.original`; its service defaults to
`docker` because access to the Docker socket is deliberately not granted.

## Scope and security

This is a local-development profile, not the production logging design:

- Elastic security is disabled, therefore every published port is bound to
  `127.0.0.1`;
- the Docker socket is not mounted; Logstash gets read-only access only to
  `/var/lib/docker/containers`;
- containers drop Linux capabilities and have memory, CPU and PID limits;
- Elasticsearch data and Logstash checkpoints use named volumes;
- indices are deleted after seven days to bound disk consumption.

On Docker Desktop, the Linux host path containing container logs is inside the
Docker VM and cannot normally be mounted this way. Use a Filebeat/Elastic Agent
input or a Docker logging driver there. This repository's native Linux setup
uses Docker's default `json-file` logging driver.

## Operations

Check ingestion:

```sh
curl -fsS 'http://localhost:9200/nexus-logs-*/_count?pretty'
docker compose -f infrastructure/observability/docker-compose.yaml logs logstash
```

Stop while retaining local data:

```sh
docker compose -f infrastructure/observability/docker-compose.yaml down
```

Delete ELK data explicitly:

```sh
docker compose -f infrastructure/observability/docker-compose.yaml down --volumes
```
