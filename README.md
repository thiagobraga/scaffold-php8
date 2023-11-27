<p align="center">
  <img src=".github/docker-php.png" width="198" />
</p>

<h1 align="center">Scaffold PHP 8 Docker Image</h1>

<br>

A Docker image created on top of [**php-fpm 8.0** official image](https://hub.docker.com/_/php) running on Alpine 3.16. It is a multi-environment/multi-purpose image that has several PHP extensions installed, such as MongoDB and Xdebug for example.

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

- **dependencies**: `freetype` `ghostscript` `gifsicle` `icu` `imagemagick` `jpegoptim` `less` `libjpeg-turbo` `libldap` `libpng` `libpq` `libzip-dev` `openssh-client` `optipng` `pngquant` `procps` `sed` `shadow`

- **build-dependencies**: `freetype-dev` `icu-dev` `imagemagick-dev` `libedit-dev` `libjpeg-turbo-dev` `libpng-dev` `libxml2-dev` `linux-headers` `oniguruma-dev` `openldap-dev` `postgresql-dev`

<br>

### PHP Extensions

- **`mongodb`** **`redis`** **`xdebug`** `bcmath` `calendar` `exif` `gd` `imagick` `intl` `ldap` `mbstring` `mysqli` `opcache` `pcntl` `pdo` `pdo_mysql` `pdo_pgsql` `soap` `sockets` `xml` `zip`

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
#7 185.4 All settings correct for using Composer
#7 185.4 Downloading...
#7 189.6 
#7 189.6 Composer (version 2.6.5) successfully installed to: /usr/local/bin/composer
#7 189.6 Use it: php /usr/local/bin/composer
#7 189.6 
#7 189.6 + curl -L https://github.com/jwilder/dockerize/releases/download/v0.7.0/dockerize-alpine-linux-amd64-v0.7.0.tar.gz
#7 189.6 + tar xz
#7 189.6   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
#7 189.6                                  Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 5624k  100 5624k    0     0  5511k      0  0:00:01  0:00:01 --:--:-- 24.6M
#7 190.7 + mv dockerize /usr/local/bin/dockerize
#7 190.7 + mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
#7 190.7 + apk del .build-deps
#7 190.7 WARNING: Ignoring https://dl-cdn.alpinelinux.org/alpine/v3.16/main: No such file or directory
#7 190.7 WARNING: Ignoring https://dl-cdn.alpinelinux.org/alpine/v3.16/community: No such file or directory
#7 190.7 (1/43) Purging .build-deps (20231127.020239)
#7 190.7 (2/43) Purging autoconf (2.71-r0)
#7 190.7 (3/43) Purging m4 (1.4.19-r1)
#7 190.7 (4/43) Purging dpkg-dev (1.21.8-r0)
#7 190.7 (5/43) Purging perl (5.34.2-r0)
#7 190.7 (6/43) Purging dpkg (1.21.8-r0)
#7 190.7 (7/43) Purging file (5.41-r0)
#7 190.7 (8/43) Purging g++ (11.2.1_git20220219-r2)
#7 190.7 (9/43) Purging gcc (11.2.1_git20220219-r2)
#7 190.7 (10/43) Purging binutils (2.38-r3)
#7 190.8 (11/43) Purging libatomic (11.2.1_git20220219-r2)
#7 190.8 (12/43) Purging libc-dev (0.7.2-r3)
#7 190.8 (13/43) Purging musl-dev (1.2.3-r3)
#7 190.8 (14/43) Purging make (4.3-r0)
#7 190.8 (15/43) Purging re2c (2.1.1-r0)
#7 190.8 (16/43) Purging freetype-dev (2.12.1-r0)
#7 190.8 (17/43) Purging icu-dev (71.1-r2)
#7 190.8 (18/43) Purging imagemagick-dev (7.1.0.50-r0)
#7 190.8 (19/43) Purging imagemagick-c++ (7.1.0.50-r0)
#7 190.8 (20/43) Purging libedit-dev (20210910.3.1-r0)
#7 190.8 (21/43) Purging ncurses-dev (6.3_p20220521-r1)
#7 190.8 (22/43) Purging libjpeg-turbo-dev (2.1.3-r1)
#7 190.8 (23/43) Purging libpng-dev (1.6.37-r1)
#7 190.8 (24/43) Purging libxml2-dev (2.9.14-r2)
#7 190.8 (25/43) Purging linux-headers (5.16.7-r1)
#7 190.8 (26/43) Purging oniguruma-dev (6.9.8-r0)
#7 190.8 (27/43) Purging openldap-dev (2.6.3-r3)
#7 190.8 (28/43) Purging cyrus-sasl-dev (2.1.28-r1)
#7 190.8 (29/43) Purging libevent-dev (2.1.12-r4)
#7 190.8 (30/43) Purging python3 (3.10.13-r0)
#7 190.8 (31/43) Purging libevent (2.1.12-r4)
#7 190.8 (32/43) Purging libsodium-dev (1.0.18-r0)
#7 190.8 (33/43) Purging util-linux-dev (2.38-r1)
#7 190.8 (34/43) Purging libfdisk (2.38-r1)
#7 190.8 (35/43) Purging libsmartcols (2.38-r1)
#7 190.8 (36/43) Purging libuuid (2.38-r1)
#7 190.8 (37/43) Purging libmagic (5.41-r0)
#7 190.8 (38/43) Purging isl22 (0.22-r0)
#7 190.8 (39/43) Purging mpc1 (1.2.1-r0)
#7 190.8 (40/43) Purging mpfr4 (4.1.0-r0)
#7 190.8 (41/43) Purging brotli-dev (1.0.9-r6)
#7 190.8 (42/43) Purging mpdecimal (2.5.1-r1)
#7 190.8 (43/43) Purging openssl-dev (1.1.1w-r1)
#7 190.8 Executing busybox-1.35.0-r17.trigger
#7 190.8 OK: 185 MiB in 120 packages
#7 190.8 + rm -rf '/var/cache/apk/*' /tmp/pear
#7 DONE 190.9s
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
#7 210.3 All settings correct for using Composer
#7 210.3 Downloading...
#7 214.3 
#7 214.3 Composer (version 2.6.5) successfully installed to: /usr/local/bin/composer
#7 214.3 Use it: php /usr/local/bin/composer
#7 214.3 
#7 214.3 + curl -L https://github.com/jwilder/dockerize/releases/download/v0.7.0/dockerize-alpine-linux-amd64-v0.7.0.tar.gz
#7 214.3 + tar xz
#7 214.3   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
#7 214.3                                  Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 5624k  100 5624k    0     0  6378k      0 --:--:-- --:--:-- --:--:-- 35.2M
#7 215.2 + mv dockerize /usr/local/bin/dockerize
#7 215.2 + mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
#7 215.2 + apk del .build-deps
#7 215.2 WARNING: Ignoring https://dl-cdn.alpinelinux.org/alpine/v3.16/main: No such file or directory
#7 215.2 WARNING: Ignoring https://dl-cdn.alpinelinux.org/alpine/v3.16/community: No such file or directory
#7 215.2 (1/43) Purging .build-deps (20231127.031846)
#7 215.2 (2/43) Purging autoconf (2.71-r0)
#7 215.2 (3/43) Purging m4 (1.4.19-r1)
#7 215.2 (4/43) Purging dpkg-dev (1.21.8-r0)
#7 215.2 (5/43) Purging perl (5.34.2-r0)
#7 215.2 (6/43) Purging dpkg (1.21.8-r0)
#7 215.2 (7/43) Purging file (5.41-r0)
#7 215.2 (8/43) Purging g++ (11.2.1_git20220219-r2)
#7 215.2 (9/43) Purging gcc (11.2.1_git20220219-r2)
#7 215.3 (10/43) Purging binutils (2.38-r3)
#7 215.3 (11/43) Purging libatomic (11.2.1_git20220219-r2)
#7 215.3 (12/43) Purging libc-dev (0.7.2-r3)
#7 215.3 (13/43) Purging musl-dev (1.2.3-r3)
#7 215.3 (14/43) Purging make (4.3-r0)
#7 215.3 (15/43) Purging re2c (2.1.1-r0)
#7 215.3 (16/43) Purging freetype-dev (2.12.1-r0)
#7 215.3 (17/43) Purging icu-dev (71.1-r2)
#7 215.3 (18/43) Purging imagemagick-dev (7.1.0.50-r0)
#7 215.3 (19/43) Purging imagemagick-c++ (7.1.0.50-r0)
#7 215.3 (20/43) Purging libedit-dev (20210910.3.1-r0)
#7 215.3 (21/43) Purging ncurses-dev (6.3_p20220521-r1)
#7 215.3 (22/43) Purging libjpeg-turbo-dev (2.1.3-r1)
#7 215.3 (23/43) Purging libpng-dev (1.6.37-r1)
#7 215.3 (24/43) Purging libxml2-dev (2.9.14-r2)
#7 215.3 (25/43) Purging linux-headers (5.16.7-r1)
#7 215.3 (26/43) Purging oniguruma-dev (6.9.8-r0)
#7 215.3 (27/43) Purging openldap-dev (2.6.3-r3)
#7 215.3 (28/43) Purging cyrus-sasl-dev (2.1.28-r1)
#7 215.3 (29/43) Purging libevent-dev (2.1.12-r4)
#7 215.3 (30/43) Purging python3 (3.10.13-r0)
#7 215.3 (31/43) Purging libevent (2.1.12-r4)
#7 215.3 (32/43) Purging libsodium-dev (1.0.18-r0)
#7 215.3 (33/43) Purging util-linux-dev (2.38-r1)
#7 215.3 (34/43) Purging libfdisk (2.38-r1)
#7 215.3 (35/43) Purging libsmartcols (2.38-r1)
#7 215.3 (36/43) Purging libuuid (2.38-r1)
#7 215.3 (37/43) Purging libmagic (5.41-r0)
#7 215.3 (38/43) Purging isl22 (0.22-r0)
#7 215.3 (39/43) Purging mpc1 (1.2.1-r0)
#7 215.3 (40/43) Purging mpfr4 (4.1.0-r0)
#7 215.3 (41/43) Purging brotli-dev (1.0.9-r6)
#7 215.3 (42/43) Purging mpdecimal (2.5.1-r1)
#7 215.3 (43/43) Purging openssl-dev (1.1.1w-r1)
#7 215.3 Executing busybox-1.35.0-r17.trigger
#7 215.3 OK: 185 MiB in 120 packages
#7 215.3 + rm -rf '/var/cache/apk/*' /tmp/pear
#7 DONE 215.4s
```

[docker-php-logo]: .github/docker-php.png
