# Observability baseline

NEXUS uses structured logs plus OpenTelemetry traces with Serverpod 3.4.11.

## Correlation

Kong creates an `x-request-id` when it is absent and returns it to the caller.
Every REST boundary (Identity, Users, Parties, Projects and AI Gateway) also
validates the value: 8–128 ASCII letters, digits, `.`, `_`, `:` or `-`. Invalid
or missing values are replaced with a random UUID and the effective value is
returned in the response. AI Gateway forwards it to Projects. Durable AI jobs
reuse the persisted run request UUID, so worker events remain correlated after
the original HTTP request ends.

Clients should send the response request id when reporting an incident. Never
put an email, token, tenant name or other business value in this header.

## Logs and metrics

HTTP boundaries emit one JSON object per request with `timestamp`, `service`,
`event=http_request`, `request_id`, `method`, `status_code` and `duration_ms`.
They do not log URLs, query strings, request bodies, credentials or subject
identifiers. Serverpod persists these session logs using its configured log
settings. Boundary failures only record the bounded `outcome` value; raw
exceptions and stack traces are intentionally excluded because their messages
may contain payloads, credentials or user identifiers.

AI workers additionally emit `event=ai_run_processed` with:

- `outcome` (`completed`, `cancelled`, or `failed`)
- `queue_wait_ms`
- `duration_ms`
- `reasoning_level` when available

These low-cardinality JSON fields can be turned into counters and histograms by
the existing log backend. Serverpod's built-in server health metrics continue
to be written to `serverpod_health_metric`.

Recommended alerts are failed HTTP ratio, p95 HTTP duration, AI failed ratio,
p95 `queue_wait_ms`, and p95 AI `duration_ms`. Do not use request ids, user ids,
project ids or tenant ids as metric labels.

## Distributed tracing and export

Every public HTTP boundary creates an OpenTelemetry server span, extracts W3C
`traceparent`/`baggage`, and injects that context into supported outbound HTTP
calls. Trace and span identifiers are included in structured logs alongside the
request id. APIs export OTLP/HTTP to the Collector, which batches and forwards
traces to Jaeger in the local observability stack.

Development samples every trace. Production should set an appropriate
parent-based sampling ratio and replace the local Jaeger exporter with the
organization tracing backend. Credentials and business identifiers must never
be added as span attributes or baggage.

## Quick check

```sh
curl -i -H 'x-request-id: local-check-1234' http://localhost:8000/v1/ai/health
```

The response must include `x-request-id: local-check-1234`, and AI Gateway logs
must contain a matching JSON `http_request` event.

## Local ELK workspace

An optional, resource-bounded Elasticsearch, Logstash and Kibana stack is
available under [`observability/`](observability/README.md). It tails Docker
logs without mounting the Docker socket and provisions the NEXUS operational
dashboard automatically. It is intended for local diagnosis; production must
use authenticated, encrypted and redundant observability infrastructure.
