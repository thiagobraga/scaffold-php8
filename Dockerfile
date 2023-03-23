# php-fpm 8.0 base image
# ------------------------------------------------------------------------------
FROM php:8.0-fpm-alpine3.13 AS fpm-base

ARG COMPOSER_MEMORY_LIMIT
ARG PHP_DATE_TIMEZONE
ARG PHP_FPM_LISTEN
ARG PHP_FPM_MAX_CHILDREN
ARG PHP_FPM_REQUEST_TERMINATE_TIMEOUT
ARG PHP_MAX_EXECUTION_TIME
ARG PHP_MAX_INPUT_VARS
ARG PHP_MEMORY_LIMIT
ARG PHP_POST_MAX_SIZE
ARG PHP_UPLOAD_MAX_FILESIZE

ENV ASUSER= \
  UID= \
  COMPOSER_ALLOW_SUPERUSER=1 \
  COMPOSER_MEMORY_LIMIT=${COMPOSER_MEMORY_LIMIT:--1} \
  ENTRYPOINT=entrypoint.php.sh \
  PHP_DATE_TIMEZONE=${PHP_DATE_TIMEZONE:-UTC} \
  PHP_FPM_LISTEN=${PHP_FPM_LISTEN:-9000} \
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
  && curl -L https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-alpine-linux-amd64-v0.6.1.tar.gz | tar xz \
  && mv dockerize /usr/local/bin/dockerize \
  && apk update \
  && apk add \
    bash freetype ghostscript gifsicle git icu imagemagick jpegoptim \
    less libjpeg-turbo libldap libpng libpq libzip-dev \
    openssh-client optipng pngquant procps sed shadow su-exec \
  && apk add --virtual .build-deps ${PHPIZE_DEPS} \
    freetype-dev icu-dev imagemagick-dev libedit-dev \
    libjpeg-turbo-dev libpng-dev libxml2-dev linux-headers \
    oniguruma-dev openldap-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

EXPOSE ${PHP_FPM_LISTEN}
CMD php-fpm

# php-fpm 8.0 for development environment
# ------------------------------------------------------------------------------
FROM fpm-base AS fpm-dev
ARG ENABLE_XDEBUG
ENV ENABLE_XDEBUG=${ENABLE_XDEBUG:-false}
RUN docker-php-ext-install -j$(nproc) \
    bcmath calendar exif gd intl ldap mbstring mysqli \
    pcntl pdo pdo_mysql soap sockets xml zip \
  && pecl install imagick mongodb redis xdebug \
  && docker-php-ext-enable imagick \
  && docker-php-ext-enable mongodb \
  && docker-php-ext-enable redis \
  && cp "/usr/local/etc/php/php.ini-development" "/usr/local/etc/php/php.ini" \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/* /tmp/*

COPY fpm/scaffold.ini /scaffold/scaffold.tmpl
COPY fpm/zz-docker.conf /scaffold/zz-docker.tmpl
COPY fpm/entrypoint /scaffold/entrypoint
RUN chmod +x /scaffold/entrypoint
ENTRYPOINT /scaffold/entrypoint

# php-fpm 8.0 for production environment
# ------------------------------------------------------------------------------
FROM fpm-base AS fpm-prod
RUN docker-php-ext-install -j$(nproc) \
    bcmath calendar exif gd intl ldap mbstring mysqli \
    opcache pcntl pdo pdo_mysql soap sockets xml zip \
  && pecl install imagick mongodb redis \
  && docker-php-ext-enable mongodb \
  && docker-php-ext-enable imagick \
  && docker-php-ext-enable redis \
  && cp "/usr/local/etc/php/php.ini-production" "/usr/local/etc/php/php.ini" \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/* /tmp/*

COPY fpm-prod/scaffold.ini /scaffold/scaffold.tmpl
COPY fpm-prod/zz-docker.conf /scaffold/zz-docker.tmpl
COPY fpm-prod/entrypoint /scaffold/entrypoint
RUN chmod +x /scaffold/entrypoint
ENTRYPOINT /scaffold/entrypoint

# SSL certificates for nginx
# ------------------------------------------------------------------------------
FROM debian AS cert
WORKDIR /scaffold/ssl
RUN apt-get update \
  && apt-get install -y openssl \
  && openssl genrsa -des3 -passout pass:x -out server.pass.key 2048 \
  && openssl rsa -passin pass:x -in server.pass.key -out _.localhost.key \
  && openssl req -new -key _.localhost.key -out server.csr -subj "/C=XX/ST=XX/L=XX/O=Scaffold-Local/OU=Localhost/CN=*.localhost" \
  && openssl x509 -req -days 365 -in server.csr -signkey _.localhost.key -out _.localhost.crt \
  && openssl x509 -in _.localhost.crt -out _.localhost.pem \
  && rm server.pass.key

# nginx and php-fpm 8.0 for development environment
# ------------------------------------------------------------------------------
FROM fpm-dev AS nginx-fpm-dev

ARG NGINX_CLIENT_MAX_BODY_SIZE
ARG NGINX_ENTRYPOINT_WORKER_PROCESSES_AUTOTUNE
ARG NGINX_FASTCGI_BUFFER_SIZE
ARG NGINX_FASTCGI_BUFFERS
ARG NGINX_FASTCGI_READ_TIMEOUT
ARG NGINX_HTTPS
ARG NGINX_LISTEN
ARG NGINX_LISTEN_HTTPS

ENV NGINX_CLIENT_MAX_BODY_SIZE=${NGINX_CLIENT_MAX_BODY_SIZE:-25M} \
  NGINX_ENTRYPOINT_WORKER_PROCESSES_AUTOTUNE=${NGINX_ENTRYPOINT_WORKER_PROCESSES_AUTOTUNE:-true} \
  NGINX_FASTCGI_BUFFER_SIZE=${NGINX_FASTCGI_BUFFER_SIZE:-'16k'} \
  NGINX_FASTCGI_BUFFERS=${NGINX_FASTCGI_BUFFERS:-'8 8k'} \
  NGINX_FASTCGI_READ_TIMEOUT=${NGINX_FASTCGI_READ_TIMEOUT:-60s} \
  NGINX_HTTPS=${NGINX_HTTPS:-false} \
  NGINX_HTTPS_CERT=/scaffold/ssl/_.localhost.pem \
  NGINX_HTTPS_CERT_KEY=/scaffold/ssl/_.localhost.key \
  NGINX_INDEX=index.php \
  NGINX_LISTEN=${NGINX_LISTEN:-80} \
  NGINX_LISTEN_HTTPS=${NGINX_LISTEN_HTTPS:-443} \
  NGINX_PHP_FPM=unix:/run/php-fpm.sock \
  NGINX_ROOT=/app/public \
  PHP_FPM_LISTEN=/run/php-fpm.sock

RUN curl -L https://github.com/ochinchina/supervisord/releases/download/v0.6.3/supervisord_static_0.6.3_linux_amd64 -o /usr/local/bin/supervisord \
  && chmod +x /usr/local/bin/supervisord \
  && apk add --no-cache nginx \
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
  && chmod +x /scaffold/30-tune-worker-processes.sh

COPY nginx-fpm/supervisor.conf /scaffold/supervisor.conf
COPY nginx-fpm/default.tmpl /scaffold/default.tmpl
COPY nginx-fpm/entrypoint /scaffold/entrypoint
COPY --from=cert /scaffold/ssl /scaffold/ssl
RUN chmod +x /scaffold/entrypoint

EXPOSE ${NGINX_LISTEN}
CMD supervisord -c /scaffold/supervisor.conf

# nginx and php-fpm 8.0 for production environment
# ------------------------------------------------------------------------------
FROM fpm-dev AS nginx-fpm-prod

ARG NGINX_CLIENT_MAX_BODY_SIZE
ARG NGINX_ENTRYPOINT_WORKER_PROCESSES_AUTOTUNE
ARG NGINX_FASTCGI_BUFFER_SIZE
ARG NGINX_FASTCGI_BUFFERS
ARG NGINX_FASTCGI_READ_TIMEOUT
ARG NGINX_HTTPS
ARG NGINX_LISTEN
ARG NGINX_LISTEN_HTTPS

ENV NGINX_CLIENT_MAX_BODY_SIZE=${NGINX_CLIENT_MAX_BODY_SIZE:-25M} \
  NGINX_ENTRYPOINT_WORKER_PROCESSES_AUTOTUNE=${NGINX_ENTRYPOINT_WORKER_PROCESSES_AUTOTUNE:-true} \
  NGINX_FASTCGI_BUFFER_SIZE=${NGINX_FASTCGI_BUFFER_SIZE:-'16k'} \
  NGINX_FASTCGI_BUFFERS=${NGINX_FASTCGI_BUFFERS:-'8 8k'} \
  NGINX_FASTCGI_READ_TIMEOUT=${NGINX_FASTCGI_READ_TIMEOUT:-60s} \
  NGINX_HTTPS=${NGINX_HTTPS:-false} \
  NGINX_HTTPS_CERT=/scaffold/ssl/_.localhost.pem \
  NGINX_HTTPS_CERT_KEY=/scaffold/ssl/_.localhost.key \
  NGINX_INDEX=index.php \
  NGINX_LISTEN=${NGINX_LISTEN:-80} \
  NGINX_LISTEN_HTTPS=${NGINX_LISTEN_HTTPS:-443} \
  NGINX_PHP_FPM=unix:/run/php-fpm.sock \
  NGINX_ROOT=/app/public \
  PHP_FPM_LISTEN=/run/php-fpm.sock

RUN curl -L https://github.com/ochinchina/supervisord/releases/download/v0.6.3/supervisord_static_0.6.3_linux_amd64 -o /usr/local/bin/supervisord \
  && chmod +x /usr/local/bin/supervisord \
  && apk add --no-cache nginx \
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
  && chmod +x /scaffold/30-tune-worker-processes.sh

COPY nginx-fpm/supervisor.conf /scaffold/supervisor.conf
COPY nginx-fpm/default.tmpl /scaffold/default.tmpl
COPY nginx-fpm/entrypoint /scaffold/entrypoint
COPY --from=cert /scaffold/ssl /scaffold/ssl
RUN chmod +x /scaffold/entrypoint

EXPOSE ${NGINX_LISTEN}
CMD supervisord -c /scaffold/supervisor.conf