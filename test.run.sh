#!/bin/bash

TAG="${1:-fpm-dev}"
DOCKER_IMAGE="thiagobraga/scaffold-php8:${TAG}"

docker run ${DOCKER_IMAGE} whoami \
  && docker run ${DOCKER_IMAGE} id \
  && docker run ${DOCKER_IMAGE} php -v \
  && docker run ${DOCKER_IMAGE} php-fpm -v \
  && docker run ${DOCKER_IMAGE} composer -V \
  && docker run ${DOCKER_IMAGE} sh -c "whoami && ls -lha" \
  && docker run -e ASUSER=0 ${DOCKER_IMAGE} whoami \
  && docker run -e ASUSER=0 ${DOCKER_IMAGE} id \
  && docker run -e ASUSER=0 ${DOCKER_IMAGE} php -v \
  && docker run -e ASUSER=0 ${DOCKER_IMAGE} php-fpm -v \
  && docker run -e ASUSER=0 ${DOCKER_IMAGE} composer -V \
  && docker run -e ASUSER=0 ${DOCKER_IMAGE} sh -c "whoami && ls -lha"

if [[ ${TAG} =~ 'fpm-dev' ]]; then
  docker run ${DOCKER_IMAGE} php -m | grep xdebug \
    && docker run -e ENABLE_XDEBUG=false ${DOCKER_IMAGE} php -m | grep xdebug || echo 'Xdebug not installed' \
    && docker run -e ASUSER=0 ${DOCKER_IMAGE} php -m | grep xdebug \
    && docker run -e ASUSER=0 -e ENABLE_XDEBUG=false ${DOCKER_IMAGE} php -m | grep xdebug || echo 'Xdebug not installed'
fi

if [[ ${TAG} =~ 'fpm-prod' ]]; then
  docker run ${DOCKER_IMAGE} sh -c "php -m | grep -i opcache | cut -d' ' -f2" \
    && docker run -e ASUSER=0 ${DOCKER_IMAGE} sh -c "php -m | grep -i opcache | cut -d' ' -f2"
fi

if [[ ${TAG} =~ 'nginx' ]]; then
  docker run ${DOCKER_IMAGE} nginx -v \
    && docker run ${DOCKER_IMAGE} nginx -t \
    && docker run ${DOCKER_IMAGE} supervisord version \
    && docker run -e ASUSER=0 ${DOCKER_IMAGE} nginx -v \
    && docker run -e ASUSER=0 ${DOCKER_IMAGE} nginx -t \
    && docker run -e ASUSER=0 ${DOCKER_IMAGE} supervisord version
fi

if [[ ${TAG} == 'quality' ]]; then
  docker run ${DOCKER_IMAGE} phan -v \
    && docker run ${DOCKER_IMAGE} phpcpd -v \
    && docker run ${DOCKER_IMAGE} phpcs --version \
    && docker run ${DOCKER_IMAGE} phpcbf --version \
    && docker run ${DOCKER_IMAGE} php-cs-fixer -V \
    && docker run ${DOCKER_IMAGE} phpmd --version \
    && docker run ${DOCKER_IMAGE} phpstan -V \
    && docker run ${DOCKER_IMAGE} phpunit --version \
    && docker run -e ASUSER=0 ${DOCKER_IMAGE} phan -v \
    && docker run -e ASUSER=0 ${DOCKER_IMAGE} phpcpd -v \
    && docker run -e ASUSER=0 ${DOCKER_IMAGE} phpcs --version \
    && docker run -e ASUSER=0 ${DOCKER_IMAGE} phpcbf --version \
    && docker run -e ASUSER=0 ${DOCKER_IMAGE} php-cs-fixer -V \
    && docker run -e ASUSER=0 ${DOCKER_IMAGE} phpmd --version \
    && docker run -e ASUSER=0 ${DOCKER_IMAGE} phpstan -V \
    && docker run -e ASUSER=0 ${DOCKER_IMAGE} phpunit --version
fi
