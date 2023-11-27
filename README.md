<p align="center">
  <img src=".github/docker-php.png" width="198" />
</p>

<h1 align="center">Scaffold PHP 8 Docker Image</h1>

<br>

A Docker image created on top of [**php-fpm 8.0** official image](https://hub.docker.com/_/php) running on Alpine 3.16. It is a multi-environment/multi-purpose image that has several PHP extensions installed, such as MongoDB and Xdebug for example.

The final size of the images is considerably small if you take into account the content of each image:

```
thiagobraga/scaffold-php8:fpm-dev          274MB
thiagobraga/scaffold-php8:fpm-prod         275MB
thiagobraga/scaffold-php8:nginx-fpm-dev    318MB
thiagobraga/scaffold-php8:nginx-fpm-prod   319MB
thiagobraga/scaffold-php8:quality          341MB
```

<br>

> Based on [**kooldev/php**](https://github.com/kool-dev/docker-php) docker image
> _from [Firework Web](https://github.com/fireworkweb)_

<br>

**Summary**

<!-- TOC -->

- [Usage](#usage)
- [Tags](#tags)
- [Contents](#contents)
  - [Core](#core)
  - [Tools](#tools)
  - [Libs](#libs)
  - [PHP Extensions](#php-extensions)
  - [Nginx best practices](#nginx-best-practices)
  - [Quality Tools](#quality-tools)
- [Info](#info)

<!-- /TOC -->

<br>

## Usage

<br>

```Dockerfile
FROM thiagobraga/scaffold-php8:fpm-dev
FROM thiagobraga/scaffold-php8:fpm-prod
FROM thiagobraga/scaffold-php8:nginx-fpm-dev
FROM thiagobraga/scaffold-php8:nginx-fpm-prod
FROM thiagobraga/scaffold-php8:quality
```

<br>

## Tags

<br>

- `fpm-dev`
- `fpm-prod`
- `nginx-fpm-dev`
- `nginx-fpm-prod`
- `quality`

<br>

## Contents

<br>

### Core

- Alpine Linux `3.16`
- php-fpm `8.0.27`
- nginx `1.22.1`

<br>

### Tools

- dockerize `0.7.0`
- supervisor `0.6.3`
- composer `2`

<br>

### Libs

- **dependencies**: `bash` `freetype` `ghostscript` `gifsicle` `icu` `imagemagick` `jpegoptim` `less` `libjpeg-turbo` `libldap` `libpng` `libpq` `libzip-dev` `openssh-client` `optipng` `pngquant` `procps` `shadow` `su-exec`

- **build-dependencies**: `freetype-dev` `icu-dev` `imagemagick-dev` `libedit-dev` `libjpeg-turbo-dev` `libpng-dev` `libxml2-dev` `linux-headers` `oniguruma-dev` `openldap-dev` `postgresql-dev`

<br>

### PHP Extensions

- **`mysqli`** **`mongodb`** **`redis`** **`xdebug`** `bcmath` `calendar` `exif` `gd` `imagick` `intl` `ldap` `mbstring` `opcache` `pcntl` `pdo` `pdo_mysql` `pdo_pgsql` `soap` `sockets` `xml` `zip`

<br>

### Nginx best practices

- **`h5bp`** `3.3.0` for nginx performance and security

<br>

### Quality Tools

- **`phan`** `5.4.2`
- **`phpcpd`** `6.0.3`
- **`phpcs`** `3.7.2`
- **`php-cs-fixer`** `3.40.0`
- **`phpmd`** `2.14.1`
- **`phpstan`** `1.10.45`
- **`phpunit`** `9.6.13`

<br>

## Info

I'm doing some comparisons between running `pecl install` for each PHP extension or run it one by time.

#1
```
#8 0.285 + adduser -D -u 1000 scaffold
#8 0.308 + addgroup scaffold www-data
#8 0.312 + apk add --no-cache freetype ghostscript gifsicle icu imagemagick jpegoptim less libjpeg-turbo libldap libpng libpq libzip-dev openssh-client optipng pngquant procps sed shadow su-exec
#8 4.501 + apk add --no-cache --virtual .build-deps autoconf dpkg-dev dpkg file g++ gcc libc-dev make pkgconf re2c freetype-dev icu-dev imagemagick-dev libedit-dev libjpeg-turbo-dev libpng-dev libxml2-dev linux-headers oniguruma-dev openldap-dev
#8 11.09 + docker-php-ext-configure gd --with-freetype --with-jpeg
#8 16.59 + export 'CFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64' 'CPPFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64' 'LDFLAGS=-Wl,-O1 -pie'
#8 16.59 + nproc
#8 16.59 + docker-php-ext-install -j8 bcmath calendar exif gd intl ldap mbstring mysqli pcntl pdo pdo_mysql soap sockets xml zip
#8 66.49 + pecl install imagick-3.5.1
#8 78.80 + pecl install mongodb-1.10.0
#8 139.1 + pecl install pcov-1.0.9
#8 146.7 + pecl install redis-5.3.4
#8 167.0 + pecl install xdebug-3.1.1
```

#2
```
#9 0.342 + adduser -D -u 1000 scaffold
#9 0.364 + addgroup scaffold www-data
#9 0.368 + apk add --no-cache bash freetype ghostscript gifsicle icu imagemagick jpegoptim less libjpeg-turbo libldap libpng libpq libzip-dev openssh-client optipng pngquant procps sed shadow su-exec
#9 5.016 + apk add --no-cache --virtual .build-deps autoconf dpkg-dev dpkg file g++ gcc libc-dev make pkgconf re2c freetype-dev icu-dev imagemagick-dev libedit-dev libjpeg-turbo-dev libpng-dev libxml2-dev linux-headers oniguruma-dev openldap-dev
#9 10.42 + docker-php-ext-configure gd --with-freetype --with-jpeg
#9 13.99 + export 'CFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64' 'CPPFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64' 'LDFLAGS=-Wl,-O1 -pie'
#9 13.99 + nproc
#9 13.99 + docker-php-ext-install -j8 bcmath calendar exif gd intl ldap mbstring mysqli pcntl pdo pdo_mysql soap sockets xml zip
#9 62.41 + pecl install imagick-3.5.1
#9 74.88 + pecl install mongodb-1.10.0
```

#3
```
#7 0.315 + adduser -D -u 1000 scaffold
#7 0.340 + addgroup scaffold www-data
#7 0.344 + apk add --no-cache bash freetype ghostscript gifsicle icu imagemagick jpegoptim less libjpeg-turbo libldap libpng libpq libzip-dev openssh-client optipng pngquant procps sed shadow su-exec
#7 8.543 + apk add --no-cache --virtual .build-deps autoconf dpkg-dev dpkg file g++ gcc libc-dev make pkgconf re2c freetype-dev icu-dev imagemagick-dev libedit-dev libjpeg-turbo-dev libpng-dev libxml2-dev linux-headers oniguruma-dev openldap-dev
#7 13.16 + docker-php-ext-configure gd --with-freetype --with-jpeg
#7 16.12 + export 'CFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64' 'CPPFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64' 'LDFLAGS=-Wl,-O1 -pie'
#7 16.12 + nproc
#7 16.12 + docker-php-ext-install -j8 bcmath calendar exif gd intl ldap mbstring mysqli pcntl pdo pdo_mysql soap sockets xml zip
#7 64.22 + pecl install imagick-3.5.1
#7 77.59 + pecl install mongodb-1.10.0
#7 137.0 + pecl install pcov-1.0.9
#7 143.9 + pecl install redis-5.3.4
#7 164.4 + pecl install xdebug-3.1.1
#7 182.6 + docker-php-ext-enable imagick mongodb pcov redis
#7 184.0 + curl -sS https://getcomposer.org/installer
#7 184.0 + php -- '--install-dir=/usr/local/bin' '--filename=composer'
```

#4
```
#7 0.372 + adduser -D -u 1000 scaffold
#7 0.395 + addgroup scaffold www-data
#7 0.399 + apk add --no-cache bash freetype ghostscript gifsicle icu imagemagick jpegoptim less libjpeg-turbo libldap libpng libpq libzip-dev openssh-client optipng pngquant procps sed shadow su-exec
#7 5.797 + apk add --no-cache --virtual .build-deps autoconf dpkg-dev dpkg file g++ gcc libc-dev make pkgconf re2c freetype-dev icu-dev imagemagick-dev libedit-dev libjpeg-turbo-dev libpng-dev libxml2-dev linux-headers oniguruma-dev openldap-dev
#7 10.45 + export 'CFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64' 'CPPFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64' 'LDFLAGS=-Wl,-O1 -pie'
#7 10.45 + docker-php-ext-configure gd --with-freetype --with-jpeg
#7 15.04 + nproc
#7 15.04 + docker-php-ext-install -j8 bcmath calendar exif gd intl ldap mbstring mysqli opcache pcntl pdo pdo_mysql soap sockets xml zip
#7 106.9 + pecl install imagick-3.5.1
#7 120.5 + pecl install mongodb-1.10.0
#7 180.7 + pecl install pcov-1.0.9
#7 187.9 + pecl install redis-5.3.4
#7 208.5 + docker-php-ext-enable imagick mongodb pcov redis
#7 209.0 + curl -sS https://getcomposer.org/installer
#7 209.0 + php -- '--install-dir=/usr/local/bin' '--filename=composer'
```

#5
```
#7 0.296 + adduser -D -u 1000 scaffold
#7 0.320 + addgroup scaffold www-data
#7 0.324 + apk add --no-cache bash freetype ghostscript gifsicle icu imagemagick jpegoptim less libjpeg-turbo libldap libpng libpq libzip-dev openssh-client optipng pngquant procps shadow su-exec
#7 4.200 + apk add --no-cache --virtual .build-deps autoconf dpkg-dev dpkg file g++ gcc libc-dev make pkgconf re2c freetype-dev icu-dev imagemagick-dev libedit-dev libjpeg-turbo-dev libpng-dev libxml2-dev linux-headers oniguruma-dev openldap-dev
#7 8.244 + docker-php-ext-configure gd --with-freetype --with-jpeg
#7 11.24 + export 'CFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64' 'CPPFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64' 'LDFLAGS=-Wl,-O1 -pie'
#7 11.24 + nproc
#7 11.24 + docker-php-ext-install -j8 bcmath calendar exif gd intl ldap mbstring mysqli pcntl pdo pdo_mysql soap sockets xml zip
#7 60.49 + pecl install imagick-3.5.1
#7 73.39 + pecl install mongodb-1.10.0
#7 132.6 + pecl install pcov-1.0.9
#7 139.2 + pecl install redis-5.3.4
#7 159.6 + pecl install xdebug-3.1.1
#7 177.2 + docker-php-ext-enable imagick mongodb pcov redis
#7 178.2 + curl -sS https://getcomposer.org/installer
#7 178.2 + php -- '--install-dir=/usr/local/bin' '--filename=composer'
```

[docker-php-logo]: https://github.com/thiagobraga/scaffold-php8/raw/main/.github/docker-php.png
