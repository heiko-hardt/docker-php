
CMD-DOCKER-IMAGE-VENDOR = hhdev
CMD-DOCKER-IMAGE-NAME = php
CMD-DOCKER-IMAGE-TIER = 8.2-apache-dev
CMD-DOCKER-USER = "${shell id -u}:${shell id -g}"

build:
	docker build \
		-f ./Dockerfile \
		--progress=plain \
		--no-cache \
		--rm \
		-t ${CMD-DOCKER-IMAGE-VENDOR}/${CMD-DOCKER-IMAGE-NAME}:${CMD-DOCKER-IMAGE-TIER} . \
		> build.log 2>&1

clean:
	@docker rmi ${CMD-DOCKER-IMAGE-VENDOR}/${CMD-DOCKER-IMAGE-NAME}:${CMD-DOCKER-IMAGE-TIER}
	@docker builder prune --all --force

up:
	@docker run -d \
		--name ${CMD-DOCKER-IMAGE-VENDOR}_${CMD-DOCKER-IMAGE-NAME}_${CMD-DOCKER-IMAGE-TIER} \
		-u ${CMD-DOCKER-USER} \
		-p 8800:8800 \
		-p 8443:8443 \
		-v ${PWD}/htdocs:/var/www/html \
		-e WEB_SERVER_NAME=localhost \
		-t ${CMD-DOCKER-IMAGE-VENDOR}/${CMD-DOCKER-IMAGE-NAME}:${CMD-DOCKER-IMAGE-TIER}
	@echo "   Start browsing: http://localhost:8800"
	@echo "                   https://localhost:8443"

down:
	@docker stop ${CMD-DOCKER-IMAGE-VENDOR}_${CMD-DOCKER-IMAGE-NAME}_${CMD-DOCKER-IMAGE-TIER}
	@docker rm ${CMD-DOCKER-IMAGE-VENDOR}_${CMD-DOCKER-IMAGE-NAME}_${CMD-DOCKER-IMAGE-TIER}

log:
	@docker logs -f ${CMD-DOCKER-IMAGE-VENDOR}_${CMD-DOCKER-IMAGE-NAME}_${CMD-DOCKER-IMAGE-TIER}

console:
	@docker exec -it ${CMD-DOCKER-IMAGE-VENDOR}_${CMD-DOCKER-IMAGE-NAME}_${CMD-DOCKER-IMAGE-TIER} /bin/bash

push:
	docker push ${CMD-DOCKER-IMAGE-VENDOR}/${CMD-DOCKER-IMAGE-NAME}:${CMD-DOCKER-IMAGE-TIER}
