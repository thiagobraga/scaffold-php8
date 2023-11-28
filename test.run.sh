#!/bin/bash

TAG="${1:-fpm-dev}"
DOCKER_IMAGE="thiagobraga/scaffold-php8:${TAG}"

docker run ${DOCKER_IMAGE} sh -c "whoami \
  && php -v | head -n1 \
  && php-fpm -v | head -n1 \
  && composer -V"

docker run -e ASUSER=0 ${DOCKER_IMAGE} sh -c "whoami \
  && php -v | head -n1 \
  && php-fpm -v | head -n1 \
  && composer -V"

if [[ ${TAG} =~ 'fpm-dev' ]]; then
  docker run ${DOCKER_IMAGE} php -m | grep xdebug \
    && docker run -e ENABLE_XDEBUG=false ${DOCKER_IMAGE} php -m | grep xdebug || echo 'Xdebug not installed' \
    && docker run -e ASUSER=0 ${DOCKER_IMAGE} php -m | grep xdebug \
    && docker run -e ASUSER=0 -e ENABLE_XDEBUG=false ${DOCKER_IMAGE} php -m | grep xdebug || echo 'Xdebug not installed'
fi

if [[ ${TAG} =~ 'fpm-prod' ]]; then
  docker run ${DOCKER_IMAGE} sh -c "whoami \
    && php -m | grep -i opcache | cut -d' ' -f2" \
  && docker run -e ASUSER=0 ${DOCKER_IMAGE} sh -c "whoami \
    && php -m | grep -i opcache | cut -d' ' -f2"
fi

if [[ ${TAG} =~ 'nginx' ]]; then
  docker run ${DOCKER_IMAGE} sh -c "nginx -v \
    && supervisord version"
  docker run -e ASUSER=0 ${DOCKER_IMAGE} sh -c "nginx -v \
    && nginx -t \
    && supervisord version"
fi

if [[ ${TAG} == 'quality' ]]; then
  docker run ${DOCKER_IMAGE} sh -c "phan -v \
    && phpcpd -v \
    && phpcs --version \
    && phpcbf --version \
    && php-cs-fixer -V \
    && phpmd --version \
    && phpstan -V \
    && phpunit --version"

  docker run -e ASUSER=0 ${DOCKER_IMAGE} sh -c "phan -v \
    && phpcpd -v \
    && phpcs --version \
    && phpcbf --version \
    && php-cs-fixer -V \
    && phpmd --version \
    && phpstan -V \
    && phpunit --version"
fi
