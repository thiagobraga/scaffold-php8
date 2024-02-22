FROM php:8.0.27-fpm-alpine3.16

ARG PHP_DATE_TIMEZONE=UTC \
  PHP_FPM_MAX_CHILDREN=10 \
  PHP_FPM_REQUEST_TERMINATE_TIMEOUT=60 \
  PHP_MAX_EXECUTION_TIME=30 \
  PHP_MAX_INPUT_VARS=1000 \
  PHP_MEMORY_LIMIT=256M \
  PHP_POST_MAX_SIZE=25M \
  PHP_UPLOAD_MAX_FILESIZE=25M

ENV ASUSER=${ASUSER:-1000} \
  COMPOSER_ALLOW_SUPERUSER=1 \
  COMPOSER_MEMORY_LIMIT=${COMPOSER_MEMORY_LIMIT:--1} \
  ENABLE_XDEBUG=${ENABLE_XDEBUG:-true} \
  XDEBUG_MODE=${XDEBUG_MODE:-debug} \
  XDEBUG_CONFIG=${XDEBUG_CONFIG:-"client_host=192.168.15.20"} \
  PHP_DATE_TIMEZONE=${PHP_DATE_TIMEZONE} \
  PHP_FPM_LISTEN=9000 \
  PHP_FPM_MAX_CHILDREN=${PHP_FPM_MAX_CHILDREN} \
  PHP_FPM_REQUEST_TERMINATE_TIMEOUT=${PHP_FPM_REQUEST_TERMINATE_TIMEOUT} \
  PHP_MAX_EXECUTION_TIME=${PHP_MAX_EXECUTION_TIME} \
  PHP_MAX_INPUT_VARS=${PHP_MAX_INPUT_VARS} \
  PHP_MEMORY_LIMIT=${PHP_MEMORY_LIMIT} \
  PHP_POST_MAX_SIZE=${PHP_POST_MAX_SIZE} \
  PHP_UPLOAD_MAX_FILESIZE=${PHP_UPLOAD_MAX_FILESIZE}

WORKDIR /app
RUN set -x \
  && adduser -D -u ${ASUSER} scaffold \
  && addgroup scaffold www-data \
  && apk add --no-cache \
    bash freetype ghostscript gifsicle icu imagemagick jpegoptim less libjpeg-turbo libldap \
    libpng libpq libzip-dev openssh-client optipng pngquant procps shadow su-exec >/dev/null 2>&1 \
  && apk add --no-cache --virtual .build-deps ${PHPIZE_DEPS} \
    freetype-dev icu-dev imagemagick-dev libedit-dev libjpeg-turbo-dev libpng-dev \
    libxml2-dev linux-headers oniguruma-dev openldap-dev >/dev/null 2>&1 \
  && docker-php-ext-configure gd --with-freetype --with-jpeg >/dev/null 2>&1 \
  && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
  && docker-php-ext-install -j$(nproc) \
    bcmath calendar exif gd intl ldap mbstring mysqli \
    pcntl pdo pdo_mysql soap sockets xml zip >/dev/null 2>&1 \
  && pecl install imagick-3.7.0 >/dev/null 2>&1 \
  && pecl install mongodb-1.17.0 >/dev/null 2>&1 \
  && pecl install pcov-1.0.11 >/dev/null 2>&1 \
  && pecl install redis-6.0.2 >/dev/null 2>&1 \
  && pecl install xdebug-3.2.2 >/dev/null 2>&1 \
  && docker-php-ext-enable imagick mongodb pcov redis >/dev/null 2>&1 \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && curl -L https://github.com/jwilder/dockerize/releases/download/v0.7.0/dockerize-alpine-linux-amd64-v0.7.0.tar.gz | tar xz \
  && mv dockerize /usr/local/bin/dockerize \
  && mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/* /tmp/*

EXPOSE ${PHP_FPM_LISTEN}
COPY --chmod=755 . /scaffold/
ENTRYPOINT ["/scaffold/entrypoint"]
CMD ["php-fpm"]
