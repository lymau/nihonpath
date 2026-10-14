# ==============================================================================
# NihonPath — Local Development Environment Makefile
# Compatible with Podman Compose and Docker Compose
# ==============================================================================

COMPOSE ?= $(shell which podman >/dev/null 2>&1 && echo "podman compose" || echo "docker compose")

.PHONY: help up down restart status logs ps test clean

help:
	@echo "NihonPath Local Development Environment"
	@echo "Usage:"
	@echo "  make up       - Start all containers in the background"
	@echo "  make down     - Stop all containers"
	@echo "  make restart  - Restart all containers"
	@echo "  make status   - Show container status"
	@echo "  make logs     - Follow logs from all containers"
	@echo "  make test     - Verify health and connectivity of local services"
	@echo "  make clean    - Stop containers and remove persistent volumes"

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

restart:
	$(COMPOSE) restart

status:
	$(COMPOSE) ps

ps: status

logs:
	$(COMPOSE) logs -f

test:
	node scripts/verify-local-env.mjs

clean:
	$(COMPOSE) down -v
