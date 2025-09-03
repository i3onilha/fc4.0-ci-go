dev: up bash

up:
	@docker compose up -d app-dev

bash:
	@docker compose exec app-dev bash

ps:
	@docker compose ps

logs:
	@docker compose logs app-dev --follow

build:
	@docker compose down && docker compose build --no-cache app-dev && docker compose up -d app-dev && docker compose exec app-dev bash

build-prod:
	@docker compose down && docker compose build --no-cache app-prod && docker compose up -d app-prod

down:
	@docker compose down

t:
	@clear;go test ./...

tv:
	@clear;go test -v ./...

cover:
	@go test -coverprofile=test/coverage.out ./... && go tool cover -html=test/coverage.out -o test/coverage.html && go run test/cover.go

oracle:
	@docker compose exec oracle-dev bash

mysql:
	@mysql -h mysql-service -u default -p

server:
	@go build -o test/server main.go && cp .env-example .env && ./test/server

server-test:
	@go build -o test/server main.go && cp .env-test .env && ./test/server
