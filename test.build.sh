#!/bin/bash

export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain

TAG="${1:-fpm-dev}"
IMAGE_NAME=scaffold-php8
DOCKER_IMAGE="thiagobraga/${IMAGE_NAME}:${TAG}"

docker build -f ${TAG}/Dockerfile -t ${DOCKER_IMAGE} ${TAG}
docker rmi -f $(docker images | grep '<none>' | awk '{ print $3 }') >/dev/null 2>&1
docker images --format 'table {{.ID}}\t{{.Repository}}:{{.Tag}}\t{{.Size}}' | grep thiagobraga/${IMAGE_NAME}
