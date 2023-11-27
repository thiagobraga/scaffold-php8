#!/bin/bash

TAG="${1:-fpm-dev}"
IMAGE_NAME=scaffold-php8
DOCKER_IMAGE="thiagobraga/${IMAGE_NAME}:${TAG}"
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

for cmd in "${PHP_COMMANDS[@]}"; do docker run ${DOCKER_IMAGE} ${cmd}; done
for cmd in "${PHP_COMMANDS[@]}"; do docker run -e ASUSER=0 ${DOCKER_IMAGE} ${cmd}; done

if [ ${TAG} == 'fpm-dev' ]; then
  docker run ${DOCKER_IMAGE} php -m | grep xdebug
  docker run -e ASUSER=0 ${DOCKER_IMAGE} php -m | grep xdebug
  docker run -e ENABLE_XDEBUG=false ${DOCKER_IMAGE} php -m | grep xdebug || echo 'Xdebug not installed'
  docker run -e ASUSER=0 -e ENABLE_XDEBUG=false ${DOCKER_IMAGE} php -m | grep xdebug || echo 'Xdebug not installed'
fi

if [[ ${TAG} =~ 'nginx' ]]; then
  for cmd in "${NGINX_COMMANDS[@]}"; do docker run ${DOCKER_IMAGE} sh -c "whoami && nginx -t && ps -aux | grep nginx"; done
  for cmd in "${NGINX_COMMANDS[@]}"; do docker run ${DOCKER_IMAGE} ${cmd}; done
  for cmd in "${NGINX_COMMANDS[@]}"; do docker run -e ASUSER=0 ${DOCKER_IMAGE} ${cmd}; done
fi

if [ ${TAG} == 'quality' ]; then
  for cmd in "${QUALITY_COMMANDS[@]}"; do docker run ${DOCKER_IMAGE} ${cmd}; done
  for cmd in "${QUALITY_COMMANDS[@]}"; do docker run -e ASUSER=0 ${DOCKER_IMAGE} ${cmd}; done
fi
