# php-fpm 8.0 / MongoDB / Alpine 3.13

A Docker image with php-fpm 8.0 running on Alpine Linux 3.13 with MongoDB extension installed.

<br>

> based on [**kooldev/php**](https://github.com/kool-dev/docker-php) docker image
> _from [Firework Web](https://github.com/fireworkweb)_

<br>

## Usage

```Dockerfile
FROM scaffoldeducation/php8-mongo-alpine3.13
```

<br>

## Contents

- Alpine Linux 3.13
- php-fpm 8.0
- nginx
- supervisor 0.6.3
- composer 2
- dockerize 0.6.1
- dependencies: `bash` `freetype` `ghostscript` `gifsicle` `git` `icu` `imagemagick` `jpegoptim` `less` `libjpeg-turbo` `libldap` `libpng` `libpq` `libzip-dev` `nginx` `openssh-client` `optipng` `pngquant` `procps` `sed` `shadow`
- build-dependencies: `freetype-dev` `icu-dev` `imagemagick-dev` `libedit-dev` `libjpeg-turbo-dev` `libpng-dev` `libxml2-dev` `linux-headers` `oniguruma-dev` `openldap-dev` `postgresql-dev`
- php extensions:
  - pecl: **`imagick`** **`mongodb`** **`redis`**
  - docker-php-ext-install: `bcmath` `calendar` `exif` `gd` `intl` `ldap` `mbstring` `mysqli` `opcache` `pcntl` `pdo` `pdo_mysql` `pdo_pgsql` `soap` `sockets` `xml` `zip`
- **`h5bp`** 3.3.0 for nginx performance and security
