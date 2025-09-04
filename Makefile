.PHONY: help build up down logs clean test

# Default target
help:
	@echo "Available commands:"
	@echo "  build     - Build all Docker images"
	@echo "  up        - Start all services with Docker Compose"
	@echo "  down      - Stop all services"
	@echo "  logs      - Show logs for all services"
	@echo "  clean     - Remove all containers and volumes"
	@echo "  test      - Run tests"
	@echo "  dev       - Start only databases for local development"

# Build all Docker images
build:
	docker-compose build

# Start all services
up:
	docker-compose up --build

# Start services in background
up-d:
	docker-compose up --build -d

# Stop all services
down:
	docker-compose down

# Show logs
logs:
	docker-compose logs -f

# Show logs for specific service
logs-account:
	docker-compose logs -f account

logs-catalog:
	docker-compose logs -f catalog

logs-order:
	docker-compose logs -f order

logs-graphql:
	docker-compose logs -f graphql

# Clean up containers and volumes
clean:
	docker-compose down -v --remove-orphans
	docker system prune -f

# Start only databases for local development
dev:
	docker-compose up account_db order_db catalog_db

# Run tests
test:
	go test ./...

# Generate GraphQL code
generate:
	cd graphql && go run github.com/99designs/gqlgen generate

# Format code
fmt:
	go fmt ./...

# Lint code
lint:
	golangci-lint run

# Install dependencies
deps:
	go mod download
	go mod tidy

# Build individual services
build-account:
	docker build -f account/app.dockerfile -t account-service ./account

build-catalog:
	docker build -f catalog/app.dockerfile -t catalog-service ./catalog

build-order:
	docker build -f order/app.dockerfile -t order-service ./order

build-graphql:
	docker build -f graphql/app.dockerfile -t graphql-gateway ./graphql

# Run services locally (requires databases to be running)
run-account:
	cd account/cmd/account && DATABASE_URL="postgres://account_user:account_pass@localhost:5433/account_db?sslmode=disable" go run .

run-catalog:
	cd catalog/cmd/catalog && ELASTICSEARCH_URL="http://localhost:9200" go run .

run-order:
	cd order/cmd/order && DATABASE_URL="postgres://order_user:order_pass@localhost:5434/order_db?sslmode=disable" ACCOUNT_SERVICE_URL="localhost:8081" CATALOG_SERVICE_URL="localhost:8083" go run .

run-graphql:
	cd graphql && ACCOUNT_SERVICE_URL="localhost:8081" CATALOG_SERVICE_URL="localhost:8083" ORDER_SERVICE_URL="localhost:8082" go run .
