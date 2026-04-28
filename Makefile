.PHONY: help start stop restart logs ps update backup restore health install uninstall hardening-check

# Default target
help:
	@echo "Available targets:"
	@echo "  make start          - Start the stack"
	@echo "  make stop           - Stop the stack"
	@echo "  make restart        - Restart the stack"
	@echo "  make logs           - View logs"
	@echo "  make ps             - Show running containers"
	@echo "  make update         - Update and restart the stack"
	@echo "  make backup         - Create a backup"
	@echo "  make restore        - Restore from backup"
	@echo "  make health         - Check health of the stack"
	@echo "  make install        - Install the project (requires sudo)"
	@echo "  make uninstall      - Uninstall the project (requires sudo)"
	@echo "  make hardening-check - Run security hardening check"

# Start the stack
start:
	@scripts/start.sh

# Stop the stack
stop:
	@scripts/stop.sh

# Restart the stack
restart: stop start

# View logs
logs:
	docker compose logs -f

# Show running containers
ps:
	docker compose ps

# Update the stack
update:
	@scripts/update.sh

# Create a backup
backup:
	@scripts/backup.sh

# Restore from backup
restore:
	@scripts/restore.sh

# Check health
health:
	@scripts/check-health.sh

# Install the project
install:
	@./install.sh

# Uninstall the project
uninstall:
	@./uninstall.sh

# Run hardening check
hardening-check:
	@scripts/hardening-check.sh
