#!/bin/bash

IMAGE='thiagobraga/php8.0-fpm-mongodb-alpine3.13'

docker login
for TAG in fpm-dev fpm-prod nginx-fpm-dev nginx-fpm-prod; do
  docker build \
    -t ${IMAGE}:${TAG} \
    -f ${TAG}/Dockerfile \
    ${TAG}/
  docker push ${IMAGE}:${TAG}
done
