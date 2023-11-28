<p align="center">
  <img src="https://github.com/thiagobraga/scaffold-php8/raw/main/.github/docker-php.png" width="198" />
</p>

<h1 align="center">Scaffold PHP 8 Docker Image</h1>

<br>

A Docker image created on top of [**php-fpm 8.0** official image](https://hub.docker.com/_/php) running on Alpine 3.16. It is a multi-environment/multi-purpose image that has several PHP extensions installed, such as MongoDB and Xdebug for example.

The final size of the images is considerably small if you take into account the content of each image:

```
thiagobraga/scaffold-php8:fpm-dev          277MB
thiagobraga/scaffold-php8:fpm-prod         277MB
thiagobraga/scaffold-php8:nginx-fpm-dev    321MB
thiagobraga/scaffold-php8:nginx-fpm-prod   321MB
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
- [Check versions](#check-versions)
- [TODO](#todo)

<!-- /TOC -->

<br>

## Usage

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

| Tag                  | Description                                                                                        |
|----------------------|----------------------------------------------------------------------------------------------------|
| **`fpm-dev`**        | it has a lot of extensions installed, but not `opcache`                                            |
| **`fpm-prod`**       | it has everything from `fpm-dev` except `xdebug` and it includes `opcache`                         |
| **`nginx-fpm-dev`**  | based on `fpm-dev`, it has nginx installed with SSL support                                        |
| **`nginx-fpm-prod`** | same above but based on `fpm-prod`                                                                 |
| **`quality`**        | it descends from `fpm-dev` too but its main purpose is to run [code quality tools](#quality-tools) |

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

## Check versions

```sh
php --ri imagick  # 3.7.0
php --ri mongodb  # 1.17.0
php --ri pcov     # 1.0.11
php --ri redis    # 6.0.2
php --ri xdebug   # 3.2.2
```

<br>

## TODO

- [ ] Allow customize versions of PECL extensions
- [ ] Write tests for SSL support in nginx

<br>
