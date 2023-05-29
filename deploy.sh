#!/bin/bash

IMAGE='thiagobraga/php8.0-fpm-mongodb-alpine3.13'
echo 'Start:' $(date +'%Y-%m-%d %H:%M:%S')
docker login &> .logs/deploy-login.log
for TAG in fpm-dev fpm-prod nginx-fpm-dev nginx-fpm-prod;
do docker push ${IMAGE}:${TAG} &> .logs/deploy-${TAG}.log; done
echo 'End:  ' $(date +'%Y-%m-%d %H:%M:%S')