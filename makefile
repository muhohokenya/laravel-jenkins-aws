.PHONY: help

CONTAINER_PHP=php
CONTAINER_NODE=npm
CONTAINER_COMPOSER=composer
CONTAINER_DATABASE=mysql
CONTAINER_REDIS=redis
CONTAINER_SITE=site
CONTAINER_ARTISAN=artisan
CONTAINER_MAIL_HOG=mailhog
DOCKER_HUB_USER_NAME=muhohoweb

APP_ROOT_NAME = laravel-docker-boilerplate

USERNAME ?= $(shell bash -c 'read -p "Username: " username; echo $$username')
PASSWORD ?= $(shell bash -c 'read -s -p "Password: " pwd; echo $$pwd')

help: ## Print help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

ps:## See running containers
	@docker ps

start: ## Start all containers
	@docker-compose up --force-recreate -d

stop: ## Stop all containers
	@docker-compose stop

restart: stop start ## Restart all containers

cache: ## Cache project
	docker exec ${CONTAINER_PHP} php artisan view:cache
	docker exec ${CONTAINER_PHP} php artisan config:cache
	docker exec ${CONTAINER_PHP} php artisan event:cache
	docker exec ${CONTAINER_PHP} php artisan route:cache

cache-clear: ## Clear cache
	docker exec ${CONTAINER_PHP} php artisan cache:clear
	docker exec ${CONTAINER_PHP} php artisan view:clear
	docker exec ${CONTAINER_PHP} php artisan config:clear
	docker exec ${CONTAINER_PHP} php artisan event:clear
	docker exec ${CONTAINER_PHP} php artisan route:clear

migrate: ## Run migration files
	docker exec ${CONTAINER_PHP} php artisan migrate

migrate-fresh: ## Clear database and run all migrations
	docker exec ${CONTAINER_PHP} php artisan migrate:fresh

npm-install: ## Install frontend assets
	docker exec ${CONTAINER_NODE} npm install

build: ## Build docker images
	docker-compose build
	docker tag ${APP_ROOT_NAME}-${CONTAINER_PHP}:latest ${DOCKER_HUB_USER_NAME}/custom-${CONTAINER_PHP} #PHP
	docker tag ${APP_ROOT_NAME}-${CONTAINER_COMPOSER}:latest ${DOCKER_HUB_USER_NAME}/custom-${CONTAINER_COMPOSER} #COMPOSER
	docker tag ${APP_ROOT_NAME}-${CONTAINER_SITE}:latest ${DOCKER_HUB_USER_NAME}/custom-${CONTAINER_SITE} #SITE

push: # Push the images to docker hub
	docker push ${DOCKER_HUB_USER_NAME}/custom-${CONTAINER_PHP}
	docker push ${DOCKER_HUB_USER_NAME}/custom-${CONTAINER_COMPOSER}
	docker push ${DOCKER_HUB_USER_NAME}/custom-${CONTAINER_SITE}

publish: build push # Build and push images to docker hub