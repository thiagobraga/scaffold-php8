FROM thiagobraga/scaffold-php8:fpm-dev

ARG PHAN_VERSION=5.4.2 \
  PHPCPD_VERSION=6.0.3 \
  PHPCS_VERSION=3.7.2 \
  PHPCSFIXER_VERSION=3.40.0 \
  PHPMD_VERSION=2.14.1 \
  PHPSTAN_VERSION=1.10.45 \
  PHPUNIT_VERSION=9.6.13

ENV PHAN_VERSION=${PHAN_VERSION} \
  PHPCPD_VERSION=${PHPCPD_VERSION} \
  PHPCS_VERSION=${PHPCS_VERSION} \
  PHPCSFIXER_VERSION=${PHPCSFIXER_VERSION} \
  PHPMD_VERSION=${PHPMD_VERSION} \
  PHPSTAN_VERSION=${PHPSTAN_VERSION} \
  PHPUNIT_VERSION=${PHPUNIT_VERSION}

RUN set -x && mkdir -p /composer \
  && echo 'export PATH="${PATH}:/composer/vendor/bin"' | tee -a /etc/profile \
  && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS >/dev/null 2>&1 \
  && pecl install ast >/dev/null 2>&1 \
  && echo 'extension=ast.so' >> /usr/local/etc/php/php.ini >/dev/null 2>&1 \
  && docker-php-ext-enable xdebug >/dev/null 2>&1 \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/* /tmp/* \
  && COMPOSER_HOME=/composer composer global require \
    phan/phan:${PHAN_VERSION} \
    sebastian/phpcpd:${PHPCPD_VERSION} \
    squizlabs/php_codesniffer:${PHPCS_VERSION} \
    friendsofphp/php-cs-fixer:${PHPCSFIXER_VERSION} \
    phpmd/phpmd:${PHPMD_VERSION} \
    phpstan/phpstan:${PHPSTAN_VERSION} \
    phpunit/phpunit:${PHPUNIT_VERSION} >/dev/null 2>&1 \
  && chmod 775 -R /composer

COPY --chmod=755 . /scaffold/
ENTRYPOINT ["/scaffold/entrypoint"]
CMD ["composer", "--version"]
