
CMD-DOCKER-IMAGE-VENDOR = hhdev
CMD-DOCKER-IMAGE-NAME = php
CMD-DOCKER-IMAGE-TIER = 8.2-apache
CMD-DOCKER-USER = "$(shell id -u):$(shell id -g)"

build:
	docker build \
		-f ./Dockerfile \
		--progress=plain \
		--no-cache \
		--rm \
		-t $(CMD-DOCKER-IMAGE-VENDOR)/$(CMD-DOCKER-IMAGE-NAME):$(CMD-DOCKER-IMAGE-TIER) .

clean:
	@docker rmi $(CMD-DOCKER-IMAGE-VENDOR)/$(CMD-DOCKER-IMAGE-NAME):$(CMD-DOCKER-IMAGE-TIER)
	@docker builder prune --all --force

up:
	@docker run -d \
		--name ${CMD-DOCKER-IMAGE-VENDOR}_${CMD-DOCKER-IMAGE-NAME}_${CMD-DOCKER-IMAGE-TIER} \
		-u ${CMD-DOCKER-USER} \
		-p 8800:8800 \
		-v ${PWD}/htdocs/:/var/www/html/ \
		-e WEB_SERVER_NAME=127.0.0.1 \
		-t $(CMD-DOCKER-IMAGE-VENDOR)/$(CMD-DOCKER-IMAGE-NAME):$(CMD-DOCKER-IMAGE-TIER)
	@echo "   Start browsing: http://127.0.0.1:8800"

down:
	@docker stop ${CMD-DOCKER-IMAGE-VENDOR}_${CMD-DOCKER-IMAGE-NAME}_${CMD-DOCKER-IMAGE-TIER}
	@docker rm ${CMD-DOCKER-IMAGE-VENDOR}_${CMD-DOCKER-IMAGE-NAME}_${CMD-DOCKER-IMAGE-TIER}

console:
	@docker exec -it ${CMD-DOCKER-IMAGE-VENDOR}_${CMD-DOCKER-IMAGE-NAME}_${CMD-DOCKER-IMAGE-TIER} /bin/bash
