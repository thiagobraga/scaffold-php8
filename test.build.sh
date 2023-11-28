#!/bin/bash

export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain

TAG="${1:-fpm-dev}"
DOCKER_IMAGE=thiagobraga/scaffold-php8

docker build -f ${TAG}/Dockerfile -t ${DOCKER_IMAGE}:${TAG} ${TAG}
docker rmi -f $(docker images | grep '<none>' | awk '{ print $3 }') >/dev/null 2>&1
docker images --format 'table {{.ID}}\t{{.Repository}}:{{.Tag}}\t{{.Size}}' | grep thiagobraga/${IMAGE_NAME}
