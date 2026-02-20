# Makefile for Acquisitions API
# Provides convenient commands for Docker operations

.PHONY: help dev-up dev-down dev-logs dev-build dev-restart prod-up prod-down prod-logs prod-build clean

# Default target
help:
	@echo "Acquisitions API - Docker Commands"
	@echo "=================================="
	@echo ""
	@echo "Development Commands:"
	@echo "  make dev-up        - Start development environment with Neon Local"
	@echo "  make dev-down      - Stop development environment"
	@echo "  make dev-logs      - View development logs"
	@echo "  make dev-build     - Rebuild development containers"
	@echo "  make dev-restart   - Restart development services"
	@echo "  make dev-shell     - Open shell in app container"
	@echo "  make dev-migrate   - Run database migrations (dev)"
	@echo ""
	@echo "Production Commands:"
	@echo "  make prod-up       - Start production environment"
	@echo "  make prod-down     - Stop production environment"
	@echo "  make prod-logs     - View production logs"
	@echo "  make prod-build    - Build production image"
	@echo "  make prod-migrate  - Run database migrations (prod)"
	@echo ""
	@echo "Utility Commands:"
	@echo "  make clean         - Remove all containers and volumes"
	@echo "  make ps            - Show running containers"
	@echo "  make env-setup     - Copy .env.example to .env"

# ===================================
# Development Environment
# ===================================
dev-up:
	@echo "🚀 Starting development environment..."
	@docker-compose -f docker-compose.dev.yml up -d
	@echo "✅ Development environment started!"
	@echo "   API: http://localhost:3000"
	@echo "   Database: postgres://postgres:postgres@localhost:5432/acquisitions"

dev-down:
	@echo "🛑 Stopping development environment..."
	@docker-compose -f docker-compose.dev.yml down
	@echo "✅ Development environment stopped!"

dev-logs:
	@docker-compose -f docker-compose.dev.yml logs -f

dev-build:
	@echo "🏗️  Building development containers..."
	@docker-compose -f docker-compose.dev.yml build
	@echo "✅ Development containers built!"

dev-restart:
	@echo "🔄 Restarting development environment..."
	@docker-compose -f docker-compose.dev.yml restart
	@echo "✅ Development environment restarted!"

dev-shell:
	@docker-compose -f docker-compose.dev.yml exec app sh

dev-migrate:
	@echo "🗄️  Running database migrations (development)..."
	@docker-compose -f docker-compose.dev.yml exec app npm run db:migrate
	@echo "✅ Migrations completed!"

dev-studio:
	@echo "🎨 Opening Drizzle Studio..."
	@docker-compose -f docker-compose.dev.yml exec app npm run db:studio

# ===================================
# Production Environment
# ===================================
prod-up:
	@echo "🚀 Starting production environment..."
	@docker-compose -f docker-compose.prod.yml --env-file .env.production up -d
	@echo "✅ Production environment started!"

prod-down:
	@echo "🛑 Stopping production environment..."
	@docker-compose -f docker-compose.prod.yml down
	@echo "✅ Production environment stopped!"

prod-logs:
	@docker-compose -f docker-compose.prod.yml logs -f

prod-build:
	@echo "🏗️  Building production image..."
	@docker-compose -f docker-compose.prod.yml build
	@echo "✅ Production image built!"

prod-migrate:
	@echo "🗄️  Running database migrations (production)..."
	@docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
	@echo "✅ Migrations completed!"

# ===================================
# Utility Commands
# ===================================
clean:
	@echo "🧹 Cleaning up all Docker resources..."
	@docker-compose -f docker-compose.dev.yml down -v 2>/dev/null || true
	@docker-compose -f docker-compose.prod.yml down -v 2>/dev/null || true
	@docker system prune -f
	@echo "✅ Cleanup completed!"

ps:
	@echo "Development:"
	@docker-compose -f docker-compose.dev.yml ps
	@echo ""
	@echo "Production:"
	@docker-compose -f docker-compose.prod.yml ps

env-setup:
	@if [ ! -f .env ]; then \
		echo "📝 Creating .env from .env.example..."; \
		cp .env.example .env; \
		echo "✅ .env file created! Please update it with your values."; \
	else \
		echo "ℹ️  .env file already exists"; \
	fi
