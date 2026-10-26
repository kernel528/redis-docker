[![Build Status](https://drone.kernelsanders.biz:8443/api/badges/kernel528/redis-docker/status.svg?ref=refs/heads/main)](https://drone.kernelsanders.biz:8443/kernel528/redis-docker)
[![Latest Version](https://img.shields.io/github/v/tag/kernel528/redis-docker)](https://github.com/kernel528/redis-docker/releases/latest)
[![Docker Pulls](https://img.shields.io/docker/pulls/kernel528/redis)](https://hub.docker.com/r/kernel528/redis)
[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/kernel528/redis?sort=semver)](https://hub.docker.com/r/kernel528/redis)

# redis-docker

Maintainer: kernel528

## Overview
This repository builds a Redis image based on the upstream `redis/docker-library-redis` Alpine Dockerfile, but uses the custom base image `kernel528/alpine:3.24.3_3` and tracks Redis `8.6.7`.

Upstream reference:
- https://github.com/redis/docker-library-redis

## Project Structure
- `Dockerfile`: Redis server image build (Alpine).
- `docker-entrypoint.sh`: Upstream entrypoint logic with module loading and permission fixes.
- `redis.conf`: Sample configuration file.
- `../docker-swarm/stacks/redis-stack.yml`: Local swarm stack deployment template.

## Build
```bash
docker image build --no-cache -t kernel528/redis:8.6.7-3.24.3_3 -f Dockerfile .
```

## Run
Standalone server:
```bash
docker container run -d --name redis -p 6379:6379 kernel528/redis:8.6.7-3.24.3_3
```

CLI only:
```bash
docker container run -it --rm kernel528/redis:8.6.7-3.24.3_3 redis-cli --version
```

## Refresh Workflow
1) Update `Dockerfile` base image and Redis source URL/SHA to match the desired upstream release.
2) Update `.drone.yml` tags for the Redis and base-image versions.
3) Build and test locally.
4) Open a PR targeting `8`. Rootless validation builds and smoke-tests the exact image without registry credentials or publication.
5) Merge to `8` to build and publish a unique non-deployable candidate; merge to `main` after promotion validation.
6) Create a Git tag from reviewed `main` using the existing `8.6.7-YYMMDD` convention. The tag pipeline freshly builds and smoke-tests Redis, refuses to overwrite the immutable tag, then updates `8`, `8.6.7`, and `latest` to the tested image.

## Repository Relationships

This independent repository is coordinated by [`docker-workspace`](https://github.com/kernel528/docker-workspace), consumes [`kernel528/alpine`](https://github.com/kernel528/alpine-docker), and publishes `kernel528/redis` for [`docker-swarm`](https://github.com/kernel528/docker-swarm). Publish and verify the Alpine tag before a base refresh. Publish and smoke-test the immutable Redis release before updating `stacks/redis-stack.yml`; deploy the stack separately and preserve the previous tag for rollback.

## CI Tagging (Drone)
- PRs targeting `8` run rootless exact-image checks and publish nothing.
- Pushes to `8` publish a unique candidate tag such as `8.6.7-3.24.3_3-drone-build-<build>-amd64`; candidate tags are not deployment inputs.
- Git tags from reviewed `main` use `8.6.7-YYMMDD` and publish immutable release tags; only after success do `8`, `8.6.7`, and `latest` move to that release.
- This repository is public and must be trusted in Drone and added to the isolated runner's exact repository allowlist after pipeline review. Rootless PR jobs receive no registry credentials.
- The smoke run uses a disposable container with persistence disabled; it does not alter the Redis stack, volumes, or deployed data.
