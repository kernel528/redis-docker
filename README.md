[![Build Status](http://drone.kernelsanders.biz:8080/api/badges/kernel528/redis-docker/status.svg?ref=refs/heads/main)](http://drone.kernelsanders.biz:8080/kernel528/redis-docker)
[![Latest Version](https://img.shields.io/github/v/tag/kernel528/redis-docker)](https://github.com/kernel528/redis-docker/releases/latest)
[![Docker Pulls](https://img.shields.io/docker/pulls/kernel528/redis)](https://hub.docker.com/r/kernel528/redis)
[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/kernel528/redis?sort=semver)](https://hub.docker.com/r/kernel528/redis)

# redis-docker

Maintainer: kernel528

## Overview
This repository builds a Redis image based on the upstream `redis/docker-library-redis` Alpine Dockerfile, but uses the custom base image `kernel528/alpine:3.23.3` and tracks Redis `8.6-rc1`.

Upstream reference:
- https://github.com/redis/docker-library-redis/tree/release/8.4/alpine

## Project Structure
- `Dockerfile`: Redis server image build (Alpine).
- `Dockerfile.arm64`: ARM64 helper image (redis-cli focused).
- `docker-entrypoint.sh`: Upstream entrypoint logic with module loading and permission fixes.
- `redis.conf`: Sample configuration file.
- `redis-stack.yml`: Local stack deployment template.

## Build
```bash
docker image build --no-cache -t kernel528/redis:8.6-rc1 -f Dockerfile .
```

## Run
Standalone server:
```bash
docker container run -d --name redis -p 6379:6379 kernel528/redis:8.6-rc1
```

CLI only:
```bash
docker container run -it --rm kernel528/redis:8.6-rc1 redis-cli --version
```

## Refresh Workflow
1) Update `Dockerfile` base image and Redis source URL/SHA to match the desired upstream release.
2) Update `.drone.yml` tags for the new Redis version (for example `8.6-rc1` and `8.6-rc1-drone-build-<build>-amd64`).
3) Build and test locally.
4) Merge into the `8` branch to publish versioned images.
5) Merge into `main` to refresh the `latest` tag, then create a Git tag for the release.

## CI Tagging (Drone)
- `8.6-rc1` branch: validation build only (no publish).
- `8` branch push: publishes versioned tags like `8` and `8.6-rc1`.
- `main` branch push: publishes `latest`.
- Git tags: publish `${DRONE_TAG}`.
