FROM php:8.0-fpm-alpine3.13 AS base

ENV ASUSER= \
  UID= \
  COMPOSER_ALLOW_SUPERUSER=1 \
  COMPOSER_MEMORY_LIMIT=-1 \
  ENTRYPOINT=entrypoint.php.sh \
  NGINX_CLIENT_MAX_BODY_SIZE=25M \
  NGINX_ENTRYPOINT_WORKER_PROCESSES_AUTOTUNE=true \
  NGINX_FASTCGI_BUFFER_SIZE='16k' \
  NGINX_FASTCGI_BUFFERS='8 8k' \
  NGINX_FASTCGI_READ_TIMEOUT=60s \
  NGINX_INDEX=index.php \
  NGINX_LISTEN=80 \
  NGINX_PHP_FPM=unix:/run/php-fpm.sock \
  NGINX_ROOT=/app/public \
  PHP_DATE_TIMEZONE=UTC \
  PHP_FPM_LISTEN=/run/php-fpm.sock \
  PHP_FPM_MAX_CHILDREN=10 \
  PHP_FPM_REQUEST_TERMINATE_TIMEOUT=60 \
  PHP_MAX_EXECUTION_TIME=30 \
  PHP_MAX_INPUT_VARS=1000 \
  PHP_MEMORY_LIMIT=256M \
  PHP_POST_MAX_SIZE=25M \
  PHP_UPLOAD_MAX_FILESIZE=25M

WORKDIR /app

COPY default.tmpl /scaffold/default.tmpl
COPY scaffold.ini /scaffold/scaffold.tmpl
COPY supervisor.conf /scaffold/supervisor.conf
COPY zz-docker.conf /scaffold/zz-docker.tmpl

RUN adduser -D -u 1337 scaffold \
  && addgroup scaffold www-data \
  && curl -L https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-alpine-linux-amd64-v0.6.1.tar.gz | tar xz \
  && mv dockerize /usr/local/bin/dockerize \
  && apk update \
  && apk add \
    bash freetype ghostscript gifsicle git icu imagemagick jpegoptim \
    less libjpeg-turbo libldap libpng libpq libzip-dev nginx \
    openssh-client optipng pngquant procps sed shadow \
  && apk add --virtual .build-deps ${PHPIZE_DEPS} \
    freetype-dev icu-dev imagemagick-dev libedit-dev \
    libjpeg-turbo-dev libpng-dev libxml2-dev linux-headers \
    oniguruma-dev openldap-dev postgresql-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
  && docker-php-ext-install -j$(nproc) \
    bcmath calendar exif gd intl ldap mbstring mysqli \
    opcache pcntl pdo pdo_mysql pdo_pgsql \
    soap sockets xml zip \
  && pecl install imagick mongodb redis \
  && docker-php-ext-enable mongodb \
  && docker-php-ext-enable imagick \
  && docker-php-ext-enable redis \
  && cp "/usr/local/etc/php/php.ini-production" "/usr/local/etc/php/php.ini" \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/* /tmp/* \
  && curl -L https://github.com/ochinchina/supervisord/releases/download/v0.6.3/supervisord_static_0.6.3_linux_amd64 -o /usr/local/bin/supervisord \
  && chmod +x /usr/local/bin/supervisord \
  && chown -R scaffold:scaffold /var/lib/nginx \
  && chmod 770 /var/lib/nginx/tmp \
  && ln -sfn /dev/stdout /var/log/nginx/access.log \
  && ln -sfn /dev/stderr /var/log/nginx/error.log \
  && mkdir -p /etc/nginx/conf.d \
  && mkdir /etc/nginx/h5bp \
  && cd /etc/nginx/h5bp \
  && wget https://github.com/h5bp/server-configs-nginx/archive/refs/tags/3.3.0.tar.gz -O h5bp.tgz \
  && tar xzvf h5bp.tgz \
  && mv server-configs-nginx-*/h5bp/* . \
  && mv server-configs-nginx-*/nginx.conf /etc/nginx/nginx.conf \
  && sed -i "s|^user .*|user\ scaffold scaffold;|g" /etc/nginx/nginx.conf \
  && mv server-configs-nginx-*/mime.types /etc/nginx/mime.types \
  && rm -rf h5bp.tgz server-configs-nginx-* \
  && curl -L https://raw.githubusercontent.com/nginxinc/docker-nginx/master/entrypoint/30-tune-worker-processes.sh -o /scaffold/30-tune-worker-processes.sh \
  && chmod +x /scaffold/30-tune-worker-processes.sh \
  && dockerize \
    -template /scaffold/scaffold.tmpl:/usr/local/etc/php/conf.d/scaffold.ini \
    -template /scaffold/zz-docker.tmpl:/usr/local/etc/php-fpm.d/zz-docker.conf \
    -template /scaffold/default.tmpl:/etc/nginx/conf.d/default.conf \
  && /scaffold/30-tune-worker-processes.sh

EXPOSE ${NGINX_LISTEN}
CMD supervisord -c /scaffold/supervisor.conf