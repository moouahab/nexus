SHELL := /usr/bin/env bash

IDENTITY_DIR := services/identity/identity_server
PROJECTS_DIR := services/projects/projects_server
USERS_DIR := services/users/users_server
PARTIES_DIR := services/parties/parties_server
AI_GATEWAY_DIR := services/ai_gateway/ai_gateway_server
KONG_DIR := infrastructure/kong
OBSERVABILITY_DIR := infrastructure/observability
GATEWAY_NETWORKS := nexus_identity_gateway nexus_users_gateway nexus_parties_gateway nexus_projects_gateway nexus_ai_gateway
TELEMETRY_NETWORK := nexus_telemetry
IDENTITY_PROJECT := identity_server
PROJECTS_PROJECT := projects_server
USERS_PROJECT := users_server
PARTIES_PROJECT := parties_server
AI_GATEWAY_PROJECT := ai_gateway_server
KONG_PROJECT := kong

.PHONY: help
help:
	@printf '%s\n' \
		'NEXUS backend commands' \
		'' \
		'Backend:' \
		'  make up                Initialize and start the complete NEXUS stack' \
		'  make stack-up          Start the complete stack from existing secrets' \
		'  make stack-down        Stop the complete stack' \
		'  make stack-ps          Show every NEXUS Compose project' \
		'  make stack-logs        Follow logs from every NEXUS Compose project' \
		'  make stack-debug-up    Publish PostgreSQL/Redis on localhost for debugging' \
		'  make observability-up  Start Elasticsearch, Logstash and Kibana' \
		'  make observability-down Stop the local observability stack' \
		'  make observability-status Show observability services' \
		'' \
		'Gateway:' \
		'  make gateway-up        Start Kong' \
		'  make gateway-down      Stop Kong' \
		'  make gateway-restart   Restart Kong' \
		'  make gateway-status    Show Kong status' \
		'  make gateway-config    Validate Kong compose and declarative config' \
		'  make infra-config      Validate all dev/prod/test Compose variants' \
		'' \
		'Services:' \
		'  make identity-init     Init Vault secrets and start Identity' \
		'  make users-init        Init Vault secrets and start Users' \
		'  make parties-init      Init Vault secrets and start Parties' \
		'  make projects-init     Init Vault secrets and start Projects' \
		'  make ai-gateway-init   Init Vault secrets and start AI Gateway' \
		'  make services-init     Init and start all service dev stacks' \
		'  make identity-up       Start Identity dev stack' \
		'  make users-up          Start Users dev stack' \
		'  make parties-up        Start Parties dev stack' \
		'  make projects-up       Start Projects dev stack' \
		'  make ai-gateway-up     Start AI Gateway dev stack' \
		'  make services-up       Start all service dev stacks' \
		'  make services-down     Stop all service dev stacks' \
		'' \
		'Quality:' \
		'  make analyze           Run dart analyze on all workspaces' \
		'  make test-auth         Test shared auth package' \
		'  make test-identity     Run Identity Serverpod tests' \
		'  make test-users        Run Users Serverpod tests' \
		'  make test-parties      Run Parties Serverpod tests' \
		'  make test-projects     Run Projects Serverpod tests' \
		'  make test-ai-gateway   Run AI Gateway Serverpod tests' \
		'  make test              Run all backend tests'

.PHONY: up stack-up stack-down stack-ps stack-logs stack-debug-up gateway-network gateway-up gateway-down gateway-restart gateway-status gateway-config infra-config
up: gateway-network services-init gateway-up

gateway-network:
	@for network in $(GATEWAY_NETWORKS) $(TELEMETRY_NETWORK); do \
		docker network inspect "$$network" >/dev/null 2>&1 || docker network create "$$network" >/dev/null; \
	done

stack-up: gateway-network services-up gateway-up

stack-down: gateway-down services-down

stack-ps:
	@for spec in \
		'$(KONG_PROJECT):$(KONG_DIR)' \
		'$(IDENTITY_PROJECT):$(IDENTITY_DIR)' \
		'$(USERS_PROJECT):$(USERS_DIR)' \
		'$(PARTIES_PROJECT):$(PARTIES_DIR)' \
		'$(PROJECTS_PROJECT):$(PROJECTS_DIR)' \
		'$(AI_GATEWAY_PROJECT):$(AI_GATEWAY_DIR)'; do \
		project="$${spec%%:*}"; directory="$${spec#*:}"; \
		printf '\n[%s]\n' "$$project"; \
		(cd "$$directory" && docker compose -p "$$project" ps); \
	done

stack-logs:
	@pids=''; \
	for spec in \
		'$(KONG_PROJECT):$(KONG_DIR)' \
		'$(IDENTITY_PROJECT):$(IDENTITY_DIR)' \
		'$(USERS_PROJECT):$(USERS_DIR)' \
		'$(PARTIES_PROJECT):$(PARTIES_DIR)' \
		'$(PROJECTS_PROJECT):$(PROJECTS_DIR)' \
		'$(AI_GATEWAY_PROJECT):$(AI_GATEWAY_DIR)'; do \
		project="$${spec%%:*}"; directory="$${spec#*:}"; \
		(cd "$$directory" && docker compose -p "$$project" logs -f) & pids="$$pids $$!"; \
	done; \
	trap 'kill $$pids 2>/dev/null || true' INT TERM EXIT; \
	wait

stack-debug-up: gateway-network
	cd $(IDENTITY_DIR) && docker compose -p $(IDENTITY_PROJECT) --profile debug up -d
	cd $(USERS_DIR) && docker compose -p $(USERS_PROJECT) --profile debug up -d
	cd $(PARTIES_DIR) && docker compose -p $(PARTIES_PROJECT) --profile debug up -d
	cd $(PROJECTS_DIR) && docker compose -p $(PROJECTS_PROJECT) --profile debug up -d
	cd $(AI_GATEWAY_DIR) && docker compose -p $(AI_GATEWAY_PROJECT) --profile debug up -d

.PHONY: observability-up observability-down observability-status
observability-up:
	docker compose -f $(OBSERVABILITY_DIR)/docker-compose.yaml up -d

observability-down:
	docker compose -f $(OBSERVABILITY_DIR)/docker-compose.yaml down

observability-status:
	docker compose -f $(OBSERVABILITY_DIR)/docker-compose.yaml ps

gateway-up: gateway-network
	cd $(KONG_DIR) && ./script/assemble-config.sh
	cd $(KONG_DIR) && docker compose -p $(KONG_PROJECT) up -d --wait

gateway-down:
	cd $(KONG_DIR) && docker compose -p $(KONG_PROJECT) down

gateway-restart: gateway-network
	cd $(KONG_DIR) && ./script/assemble-config.sh
	cd $(KONG_DIR) && docker compose -p $(KONG_PROJECT) up -d --force-recreate --wait

gateway-status:
	curl -fsS http://127.0.0.1:8100/status

gateway-config:
	cd $(KONG_DIR) && ./script/assemble-config.sh --check
	cd $(KONG_DIR) && docker compose config >/dev/null
	cd $(KONG_DIR) && docker compose run --rm kong kong config parse /kong/declarative/kong.yaml

infra-config:
	./tests/scripts/validate_infrastructure.sh

.PHONY: identity-init users-init parties-init projects-init ai-gateway-init services-init
identity-init:
	cd $(IDENTITY_DIR) && COMPOSE_PROJECT_NAME=$(IDENTITY_PROJECT) ./docker/script/setup_vault_approle.sh

users-init:
	cd $(USERS_DIR) && COMPOSE_PROJECT_NAME=$(USERS_PROJECT) ./docker/script/setup_vault_approle.sh

parties-init:
	cd $(PARTIES_DIR) && COMPOSE_PROJECT_NAME=$(PARTIES_PROJECT) ./docker/script/setup_vault_approle.sh

projects-init:
	cd $(PROJECTS_DIR) && COMPOSE_PROJECT_NAME=$(PROJECTS_PROJECT) ./docker/script/setup_vault_approle.sh

ai-gateway-init:
	cd $(AI_GATEWAY_DIR) && COMPOSE_PROJECT_NAME=$(AI_GATEWAY_PROJECT) ./docker/script/setup_vault_approle.sh

services-init: identity-init projects-init users-init parties-init ai-gateway-init

.PHONY: identity-up users-up parties-up projects-up ai-gateway-up services-up services-down
identity-up: gateway-network
	cd $(IDENTITY_DIR) && docker compose -p $(IDENTITY_PROJECT) up -d

users-up: gateway-network
	cd $(USERS_DIR) && docker compose -p $(USERS_PROJECT) up -d

parties-up: gateway-network
	cd $(PARTIES_DIR) && docker compose -p $(PARTIES_PROJECT) up -d

projects-up: gateway-network
	cd $(PROJECTS_DIR) && docker compose -p $(PROJECTS_PROJECT) up -d

ai-gateway-up: gateway-network
	cd $(AI_GATEWAY_DIR) && \
	OLLAMA_BASE_URL="$${OLLAMA_BASE_URL:-http://$$(ip route show default | awk '{print $$3; exit}'):11434}" \
	docker compose -p $(AI_GATEWAY_PROJECT) up -d

services-up: identity-up projects-up users-up parties-up ai-gateway-up

services-down:
	-cd $(AI_GATEWAY_DIR) && docker compose -p $(AI_GATEWAY_PROJECT) down
	-cd $(PARTIES_DIR) && docker compose -p $(PARTIES_PROJECT) down
	-cd $(USERS_DIR) && docker compose -p $(USERS_PROJECT) down
	-cd $(PROJECTS_DIR) && docker compose -p $(PROJECTS_PROJECT) down
	-cd $(IDENTITY_DIR) && docker compose -p $(IDENTITY_PROJECT) down

.PHONY: analyze
analyze:
	cd shared/nexus_auth && dart analyze
	cd services/identity && dart analyze
	cd services/users && dart analyze
	cd services/parties && dart analyze
	cd services/projects && dart analyze
	cd services/ai_gateway && dart analyze

.PHONY: test test-auth test-identity test-users test-parties test-projects test-ai-gateway
test: test-auth test-identity test-users test-parties test-projects test-ai-gateway

test-auth:
	cd shared/nexus_auth && dart test

test-identity:
	cd $(IDENTITY_DIR) && ./docker/script/run_serverpod_tests.sh

test-users:
	cd $(USERS_DIR) && ./docker/script/run_serverpod_tests.sh

test-parties:
	cd $(PARTIES_DIR) && ./docker/script/run_serverpod_tests.sh

test-projects:
	cd $(PROJECTS_DIR) && ./docker/script/run_serverpod_tests.sh

test-ai-gateway:
	cd $(AI_GATEWAY_DIR) && dart test

.PHONY: security-static security-probe security-full security-tooling security-authorization security-operational
security-static:
	./security/scripts/run_static.sh

security-probe:
	./security/scripts/run_dast.sh probe

security-full:
	./security/scripts/run_dast.sh full

security-tooling:
	bash -n security/scripts/run_static.sh security/scripts/run_dast.sh
	python3 -m unittest discover -s security/tests -v

security-authorization:
	./security/scripts/run_authorization.sh

security-operational:
	./security/scripts/run_operational_proofs.sh
