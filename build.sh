#!/bin/bash

# In Gitlab CI build stage, we'll need to pass all variables
# from Gitlab CI/CD Variables section to `docker build`,
# using `--build-arg` for each variable.

cat .env | xargs -d'\n' printf -- '--build-arg %s\n' | xargs \
  docker build \
    --no-cache \
    --target fpm-dev \
    -t fpm-dev \
    -f Dockerfile .

cat .env | xargs -d'\n' printf -- '--build-arg %s\n' | xargs \
  docker build \
    --no-cache \
    --target fpm-prod \
    -t fpm-prod \
    -f Dockerfile .

cat .env | xargs -d'\n' printf -- '--build-arg %s\n' | xargs \
  docker build \
    --no-cache \
    --target nginx-fpm-dev \
    -t nginx-fpm-dev \
    -f Dockerfile .

cat .env | xargs -d'\n' printf -- '--build-arg %s\n' | xargs \
  docker build \
    --no-cache \
    --target nginx-fpm-prod \
    -t nginx-fpm-prod \
    -f Dockerfile .