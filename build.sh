#!/bin/bash

IMAGE='thiagobraga/php8.0-fpm-mongodb-alpine3.13'
echo 'Start:' $(date +'%Y-%m-%d %H:%M:%S')
mkdir -p .logs
for TAG in fpm-dev fpm-prod nginx-fpm-dev nginx-fpm-prod;
do docker build --no-cache -t ${IMAGE}:${TAG} -f ${TAG}/Dockerfile ${TAG} &> .logs/build-${TAG}.log; done
echo 'End:  ' $(date +'%Y-%m-%d %H:%M:%S')