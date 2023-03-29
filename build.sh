#!/bin/bash

# In Gitlab CI build stage, we'll need to pass all variables
# from Gitlab CI/CD Variables section to `docker build`,
# using `--build-arg` for each variable.

for TAG in fpm-dev fpm-prod nginx-fpm-dev nginx-fpm-prod; do
  cat .env | \
    xargs -d'\n' printf -- '--build-arg %s\n' | \
    xargs docker build --no-cache -t ${TAG} -f ${TAG}/Dockerfile ${TAG}
done