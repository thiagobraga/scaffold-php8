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
  && rm server.pass.key \
  && apt-get remove -y openssl \
  && apt-get clean

# nginx and php-fpm 8.0 for development environment
# ------------------------------------------------------------------------------
FROM thiagobraga/scaffold-php8:fpm-prod

ARG NGINX_CLIENT_MAX_BODY_SIZE=25M \
  NGINX_FASTCGI_BUFFER_SIZE='16k' \
  NGINX_FASTCGI_BUFFERS='8 8k' \
  NGINX_FASTCGI_READ_TIMEOUT=60s \
  NGINX_HTTPS=false \
  NGINX_LISTEN=80 \
  NGINX_LISTEN_HTTPS=443

ENV NGINX_CLIENT_MAX_BODY_SIZE=${NGINX_CLIENT_MAX_BODY_SIZE} \
  NGINX_FASTCGI_BUFFER_SIZE=${NGINX_FASTCGI_BUFFER_SIZE} \
  NGINX_FASTCGI_BUFFERS=${NGINX_FASTCGI_BUFFERS} \
  NGINX_FASTCGI_READ_TIMEOUT=${NGINX_FASTCGI_READ_TIMEOUT} \
  NGINX_HTTPS=${NGINX_HTTPS} \
  NGINX_HTTPS_CERT=/scaffold/ssl/_.localhost.pem \
  NGINX_HTTPS_CERT_KEY=/scaffold/ssl/_.localhost.key \
  NGINX_INDEX=index.php \
  NGINX_LISTEN=${NGINX_LISTEN} \
  NGINX_LISTEN_HTTPS=${NGINX_LISTEN_HTTPS} \
  NGINX_PHP_FPM=unix:/run/php-fpm.sock \
  NGINX_ROOT=/app/public \
  PHP_FPM_LISTEN=/run/php-fpm.sock

RUN apk add --no-cache nginx \
  && chown -R scaffold:scaffold /var/lib/nginx \
  && chmod 770 /var/lib/nginx/tmp \
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log \
  && mkdir -p /etc/nginx/h5bp /etc/nginx/conf.d \
  && cd /etc/nginx/h5bp \
  && wget https://github.com/h5bp/server-configs-nginx/archive/refs/tags/3.3.0.tar.gz -O h5bp.tgz \
  && tar xzvf h5bp.tgz \
  && mv server-configs-nginx-*/h5bp/* . \
  && mv server-configs-nginx-*/nginx.conf /etc/nginx/nginx.conf \
  && sed -i "s|^user .*|user\ scaffold scaffold;|g" /etc/nginx/nginx.conf \
  && mv server-configs-nginx-*/mime.types /etc/nginx/mime.types \
  && rm -rf server-configs-nginx-* h5bp.tgz \
  && curl -L https://raw.githubusercontent.com/nginxinc/docker-nginx/master/entrypoint/30-tune-worker-processes.sh -o /scaffold/30-tune-worker-processes.sh \
  && chmod +x /scaffold/30-tune-worker-processes.sh \
  && rm -rf /var/cache/apk/* /tmp/*

EXPOSE ${NGINX_LISTEN} ${NGINX_LISTEN_HTTPS}
COPY --chmod=755 . /scaffold/
COPY --from=cert /scaffold/ssl /scaffold/ssl
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord
ENTRYPOINT ["/scaffold/entrypoint"]
CMD ["supervisord", "-c", "/scaffold/supervisor.conf"]
