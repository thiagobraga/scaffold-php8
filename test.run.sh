#!/bin/bash

TAG="${1:-fpm-dev}"
IMAGE_NAME=scaffold-php8
DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME:-thiagobraga}
DOCKER_IMAGE="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${TAG}"
PHP_COMMANDS=(
  'whoami'
  'php -v'
  'php-fpm -v'
  'composer -V'
)
NGINX_COMMANDS=(
  'nginx -v'
  'nginx -t'
  'supervisord version'
)
QUALITY_COMMANDS=(
  'phan -v'
  'phpcpd -v'
  'phpcs --version'
  'phpcbf --version'
  'php-cs-fixer -V'
  'phpmd --version'
  'phpstan -V'
  'phpunit --version'
)

set -x

for cmd in "${PHP_COMMANDS[@]}"; do docker run ${DOCKER_IMAGE} ${cmd}; done
for cmd in "${PHP_COMMANDS[@]}"; do docker run -e ASUSER=0 ${DOCKER_IMAGE} ${cmd}; done

if [ ${TAG} == 'fpm-dev' ]; then
  docker run ${DOCKER_IMAGE} php -m | grep xdebug
  docker run -e ASUSER=0 ${DOCKER_IMAGE} php -m | grep xdebug
  docker run -e ENABLE_XDEBUG=false ${DOCKER_IMAGE} php -m | grep xdebug || echo 'Xdebug not installed'
  docker run -e ASUSER=0 -e ENABLE_XDEBUG=false ${DOCKER_IMAGE} php -m | grep xdebug || echo 'Xdebug not installed'
fi

if [[ ${TAG} =~ 'nginx' ]]; then
  for cmd in "${NGINX_COMMANDS[@]}"; do docker run ${DOCKER_IMAGE} ${cmd}; done
  for cmd in "${NGINX_COMMANDS[@]}"; do docker run -e ASUSER=0 ${DOCKER_IMAGE} ${cmd}; done
fi

if [ ${TAG} == 'quality' ]; then
  for cmd in "${QUALITY_COMMANDS[@]}"; do docker run ${DOCKER_IMAGE} ${cmd}; done
fi
