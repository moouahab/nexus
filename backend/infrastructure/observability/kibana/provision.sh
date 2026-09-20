#!/bin/sh
set -eu

kibana_url="http://kibana:5601"
elastic_url="http://elasticsearch:9200"

curl --fail --silent --show-error \
  -X PUT "$elastic_url/_ilm/policy/nexus-local-7-days" \
  -H 'Content-Type: application/json' \
  --data-binary @/setup/ilm-policy.json >/dev/null

curl --fail --silent --show-error \
  -X POST "$kibana_url/api/data_views/data_view" \
  -H 'kbn-xsrf: nexus-observability-setup' \
  -H 'Content-Type: application/json' \
  --data '{"data_view":{"id":"nexus-logs","title":"nexus-logs-*","timeFieldName":"@timestamp","allowNoIndex":true},"override":true}' >/dev/null

curl --fail --silent --show-error \
  -X POST "$kibana_url/api/saved_objects/_import?overwrite=true" \
  -H 'kbn-xsrf: nexus-observability-setup' \
  --form file=@/setup/nexus-dashboards.ndjson >/dev/null

curl --fail --silent --show-error \
  -X POST "$kibana_url/api/kibana/settings" \
  -H 'kbn-xsrf: nexus-observability-setup' \
  -H 'Content-Type: application/json' \
  --data '{"changes":{"defaultIndex":"nexus-logs"}}' >/dev/null

echo "NEXUS Kibana data view and dashboards provisioned."
