FROM php:8.0-fpm-alpine

ARG COMPOSER_MEMORY_LIMIT
ARG PHP_DATE_TIMEZONE
ARG PHP_FPM_MAX_CHILDREN
ARG PHP_FPM_REQUEST_TERMINATE_TIMEOUT
ARG PHP_MAX_EXECUTION_TIME
ARG PHP_MAX_INPUT_VARS
ARG PHP_MEMORY_LIMIT
ARG PHP_POST_MAX_SIZE
ARG PHP_UPLOAD_MAX_FILESIZE

ENV ASUSER=${ASUSER:-} \
  UID=${UID:-} \
  COMPOSER_ALLOW_SUPERUSER=1 \
  COMPOSER_MEMORY_LIMIT=${COMPOSER_MEMORY_LIMIT:--1} \
  ENTRYPOINT=entrypoint.php.sh \
  PHP_DATE_TIMEZONE=${PHP_DATE_TIMEZONE:-UTC} \
  PHP_FPM_LISTEN=9000 \
  PHP_FPM_MAX_CHILDREN=${PHP_FPM_MAX_CHILDREN:-10} \
  PHP_FPM_REQUEST_TERMINATE_TIMEOUT=${PHP_FPM_REQUEST_TERMINATE_TIMEOUT:-60} \
  PHP_MAX_EXECUTION_TIME=${PHP_MAX_EXECUTION_TIME:-30} \
  PHP_MAX_INPUT_VARS=${PHP_MAX_INPUT_VARS:-1000} \
  PHP_MEMORY_LIMIT=${PHP_MEMORY_LIMIT:-256M} \
  PHP_POST_MAX_SIZE=${PHP_POST_MAX_SIZE:-25M} \
  PHP_UPLOAD_MAX_FILESIZE=${PHP_UPLOAD_MAX_FILESIZE:-25M}

WORKDIR /app
RUN adduser -D -u 1337 scaffold \
  && addgroup scaffold www-data \
  && apk update \
  && apk add --no-cache \
    bash freetype ghostscript gifsicle git icu imagemagick jpegoptim \
    less libjpeg-turbo libldap libpng libpq libzip-dev \
    openssh-client optipng pngquant procps sed shadow su-exec \
  && apk add --virtual .build-deps ${PHPIZE_DEPS} \
    freetype-dev icu-dev imagemagick-dev libedit-dev \
    libjpeg-turbo-dev libpng-dev libxml2-dev linux-headers \
    oniguruma-dev openldap-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
  && docker-php-ext-install -j$(nproc) \
    bcmath calendar exif gd intl ldap mbstring mysqli \
    opcache pcntl pdo pdo_mysql soap sockets xml zip \
  && pecl install imagick mongodb pcov redis \
  && docker-php-ext-enable imagick \
  && docker-php-ext-enable mongodb \
  && docker-php-ext-enable pcov \
  && docker-php-ext-enable redis \
  && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
  && curl -sL https://phar.phpunit.de/phpunit-8.phar > /usr/local/bin/phpunit \
  && chmod +x /usr/local/bin/phpunit \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/* /tmp/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
COPY --from=jwilder/dockerize:0.6.1 /usr/local/bin/dockerize /usr/local/bin/dockerize
COPY scaffold.ini /scaffold/scaffold.tmpl
COPY zz-docker.conf /scaffold/zz-docker.tmpl
COPY entrypoint /scaffold/entrypoint
RUN chmod +x /scaffold/entrypoint

EXPOSE ${PHP_FPM_LISTEN}
ENTRYPOINT ["/scaffold/entrypoint"]
CMD ["php-fpm"]
