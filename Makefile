# GenLayer Validator Setup - Makefile
# Provides convenient shortcuts for common operations

.PHONY: help install upgrade start stop restart logs health monitor clean backup

# Default target
help:
	@echo "GenLayer Validator Setup - Available Commands"
	@echo ""
	@echo "Installation:"
	@echo "  make install           - Run interactive installation"
	@echo "  make install-docker    - Install with Docker method"
	@echo "  make install-binary    - Install with Binary method"
	@echo ""
	@echo "Node Management:"
	@echo "  make start            - Start the validator node"
	@echo "  make stop             - Stop the validator node"
	@echo "  make restart          - Restart the validator node"
	@echo "  make logs             - View node logs (follow mode)"
	@echo "  make logs-tail        - View last 100 log lines"
	@echo ""
	@echo "Monitoring:"
	@echo "  make health           - Run health check"
	@echo "  make monitor          - Setup and start monitoring"
	@echo "  make monitor-start    - Start monitoring services"
	@echo "  make monitor-stop     - Stop monitoring services"
	@echo "  make metrics          - View current metrics"
	@echo ""
	@echo "Maintenance:"
	@echo "  make upgrade          - Upgrade to latest version"
	@echo "  make backup           - Backup operator key"
	@echo "  make clean            - Clean up old data"
	@echo "  make doctor           - Run node diagnostics"
	@echo ""
	@echo "Development:"
	@echo "  make validate         - Validate configuration"
	@echo "  make shell            - Open shell in node container"
	@echo ""

# Installation targets
install:
	@echo "Starting interactive installation..."
	./install.sh --interactive

install-docker:
	@echo "Installing with Docker method..."
	./install.sh --method docker

install-binary:
	@echo "Installing with Binary method..."
	./install.sh --method binary

# Node management targets
start:
	@if [ -d "node-docker" ]; then \
		cd node-docker && docker compose --profile node up -d; \
		echo "✓ Node started in Docker mode"; \
	else \
		echo "✗ Docker installation not found. Run 'make install' first"; \
		exit 1; \
	fi

stop:
	@if [ -d "node-docker" ]; then \
		cd node-docker && docker compose --profile node down; \
		echo "✓ Node stopped"; \
	else \
		echo "✗ Docker installation not found"; \
		exit 1; \
	fi

restart:
	@$(MAKE) stop
	@sleep 2
	@$(MAKE) start

logs:
	@if command -v docker >/dev/null 2>&1 && docker ps | grep -q genlayer-node; then \
		docker logs -f genlayer-node; \
	else \
		echo "✗ Node container not running"; \
		exit 1; \
	fi

logs-tail:
	@if command -v docker >/dev/null 2>&1 && docker ps | grep -q genlayer-node; then \
		docker logs --tail 100 genlayer-node; \
	else \
		echo "✗ Node container not running"; \
		exit 1; \
	fi

# Monitoring targets
health:
	@echo "Running health check..."
	@./scripts/utils/health-check.sh

monitor:
	@echo "Setting up monitoring..."
	@./scripts/setup-monitoring.sh

monitor-start:
	@if [ -d "node-docker" ]; then \
		cd node-docker && docker compose --profile monitoring up -d; \
		echo "✓ Monitoring started"; \
	else \
		echo "✗ Docker installation not found"; \
		exit 1; \
	fi

monitor-stop:
	@if [ -d "node-docker" ]; then \
		cd node-docker && docker compose --profile monitoring down; \
		echo "✓ Monitoring stopped"; \
	else \
		echo "✗ Docker installation not found"; \
		exit 1; \
	fi

metrics:
	@echo "Fetching current metrics..."
	@curl -s http://localhost:9153/metrics | head -50
	@echo ""
	@echo "Full metrics available at: http://localhost:9153/metrics"

# Maintenance targets
upgrade:
	@echo "Starting upgrade process..."
	@read -p "Enter target version (e.g., v0.4.6): " VERSION; \
	./scripts/upgrade.sh --version $$VERSION --backup

backup:
	@echo "Backing up operator key..."
	@if [ -d "node-docker" ]; then \
		read -p "Enter operator address: " ADDR; \
		read -sp "Enter node password: " PASS; echo; \
		read -sp "Enter backup passphrase: " BACKUP_PASS; echo; \
		docker exec genlayer-node /app/bin/genlayernode account export \
			--password "$$PASS" \
			--address "$$ADDR" \
			--passphrase "$$BACKUP_PASS" \
			--path "/app/data/backup-$(date +%Y%m%d-%H%M%S).key" \
			-c /app/configs/node/config.yaml; \
		echo "✓ Backup created in node-docker/data/"; \
	else \
		echo "✗ Docker installation not found"; \
		exit 1; \
	fi

clean:
	@echo "Cleaning up old data..."
	@read -p "This will remove old logs and backups. Continue? [y/N]: " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		if [ -d "node-docker/data" ]; then \
			find node-docker/data -name "*.log.gz" -mtime +7 -delete 2>/dev/null || true; \
			find node-docker/data -name "*.bak" -mtime +30 -delete 2>/dev/null || true; \
			echo "✓ Cleanup complete"; \
		fi; \
	else \
		echo "Cancelled"; \
	fi

doctor:
	@echo "Running node diagnostics..."
	@if command -v docker >/dev/null 2>&1 && docker ps | grep -q genlayer-node; then \
		docker exec genlayer-node ./bin/genlayernode doctor; \
	else \
		echo "✗ Node container not running"; \
		exit 1; \
	fi

# Development targets
validate:
	@echo "Validating configuration..."
	@if [ -f "node-docker/.env" ]; then \
		echo "Checking .env file..."; \
		grep -q "NODE_PASSWORD=CHANGE" node-docker/.env && echo "⚠ Warning: Default password detected" || true; \
		grep -q "genlayerchainrpcurl.*TODO" node-docker/configs/node/config.yaml && echo "⚠ Warning: RPC URL not configured" || true; \
		echo "✓ Basic validation complete"; \
	else \
		echo "✗ Configuration files not found. Run 'make install' first"; \
		exit 1; \
	fi

shell:
	@if command -v docker >/dev/null 2>&1 && docker ps | grep -q genlayer-node; then \
		docker exec -it genlayer-node /bin/sh; \
	else \
		echo "✗ Node container not running"; \
		exit 1; \
	fi

# Status check
status:
	@echo "GenLayer Validator Status"
	@echo "=========================="
	@echo ""
	@if command -v docker >/dev/null 2>&1; then \
		if docker ps | grep -q genlayer-node; then \
			echo "Node Status: ✓ Running"; \
			docker ps --format "  {{.Names}}: {{.Status}}" | grep genlayer; \
		else \
			echo "Node Status: ✗ Not Running"; \
		fi; \
	else \
		echo "Docker: ✗ Not installed or not accessible"; \
	fi
	@echo ""
	@if curl -s http://localhost:9153/health >/dev/null 2>&1; then \
		echo "Health Check: ✓ Passing"; \
	else \
		echo "Health Check: ✗ Failing or not accessible"; \
	fi
	@echo ""

# Quick commands
up: start
down: stop
ps: status
