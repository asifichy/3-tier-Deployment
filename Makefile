DEV_COMPOSE_FILE=docker-compose-dev.yml
DEBUG_COMPOSE_FILE=docker-compose-debug.yml
TEST_COMPOSE_FILE=docker-compose-test.yml

### DOCKER COMPOSE COMMANDS

.PHONY: compose-build
compose-build:
	docker compose -f $(DEV_COMPOSE_FILE) build

.PHONY: compose-up

compose-up:
	docker compose -f $(DEV_COMPOSE_FILE) up

.PHONY: compose-up-build

compose-up-build:
	docker compose -f $(DEV_COMPOSE_FILE) up --build

.PHONY: compose-up-debug-build

compose-up-debug-build:
	docker compose -f $(DEV_COMPOSE_FILE) -f $(DEBUG_COMPOSE_FILE) up --build

.PHONY: compose-down

compose-down:
	docker compose -f $(DEV_COMPOSE_FILE) down

### DOCKER CLI COMMANDS

DOCKERCONTEXT_DIR:=../3-tier-deployment/
DOCKERFILE_DIR:=../3-tier-deployment/

.PHONY: docker-build-all
docker-build-all:
	docker build --no-cache -t client-react-vite -f ${DOCKERFILE_DIR}/client-react/Dockerfile.3 ${DOCKERCONTEXT_DIR}/client-react/

	docker build --no-cache -t client-react-ngnix -f ${DOCKERFILE_DIR}/client-react/Dockerfile.5 ${DOCKERCONTEXT_DIR}/client-react/

	docker build --no-cache -t api-node -f ${DOCKERFILE_DIR}/api-node/Dockerfile.7 ${DOCKERCONTEXT_DIR}/api-node/

	docker build --no-cache -t api-golang -f ${DOCKERFILE_DIR}/api-golang/Dockerfile.6 ${DOCKERCONTEXT_DIR}/api-golang/

DATABASE_URL:=postgres://postgres:foobarbaz@db:5432/postgres

.PHONY: docker-run-all
docker-run-all:
	echo "$$DOCKER_COMPOSE_NOTE"

	# Stop and remove all running containers to avoid name conflicts
	$(MAKE) docker-stop

	$(MAKE) docker-rm

	docker network create my-network

	docker run -d \
		--name db \
		--network my-network \
		-e POSTGRES_PASSWORD=foobarbaz \
		-v pgdata:/var/lib/postgresql/data \
		-p 5432:5432 \
		--restart unless-stopped \
		postgres:15.1-alpine

	docker run -d \
		--name api-node \
		--network my-network \
		-e DATABASE_URL=${DATABASE_URL} \
		-p 3000:3000 \
		--restart unless-stopped \
		--link=db \
		api-node

	docker run -d \
		--name api-golang \
		--network my-network \
		-e DATABASE_URL=${DATABASE_URL} \
		-p 5000:5000 \
		--restart unless-stopped \
		--link=db \
		api-golang

	docker run -d \
		--name client-react-vite \
		--network my-network \
		-v "$(PWD)/client-react/vite.config.js:/usr/src/app/vite.config.js" \
		-p 5173:5173 \
		--restart unless-stopped \
		--link=api-node \
		--link=api-golang \
		client-react-vite

	docker run -d \
		--name client-react-nginx \
		--network my-network \
		-p 5174:8080 \
		--restart unless-stopped \
		--link=api-node \
		--link=api-golang \
		client-react-ngnix

.PHONY: docker-stop
docker-stop:
	-docker stop db
	-docker stop api-node
	-docker stop api-golang
	-docker stop client-react-vite
	-docker stop client-react-nginx

.PHONY: docker-rm
docker-rm:
	-docker container rm db
	-docker container rm api-node
	-docker container rm api-golang
	-docker container rm client-react-vite
	-docker container rm client-react-nginx
	-docker network rm my-network

define DOCKER_COMPOSE_NOTE

endef
export DOCKER_COMPOSE_NOTE