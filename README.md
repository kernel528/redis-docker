[![Build Status](http://drone.kernelsanders.biz:8080/api/badges/kernel528/redis-docker/status.svg?ref=refs/heads/main)](http://drone.kernelsanders.biz:8080/kernel528/redis-docker)
[![Latest Version](https://img.shields.io/github/v/tag/kernel528/redis-docker)](https://github.com/kernel528/redis-docker/releases/latest)
[![Docker Pulls](https://img.shields.io/docker/pulls/kernel528/redis)](https://hub.docker.com/r/kernel528/redis)
[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/kernel528/redis?sort=semver)](https://hub.docker.com/r/kernel528/redis)

# redis-docker

Maintainer: kernel528

## Overview
This repository builds a Redis image based on the upstream `redis/docker-library-redis` Alpine Dockerfile, but uses the custom base image `kernel528/alpine:3.24.1_1` and tracks Redis `8.6.4`.

Upstream reference:
- https://github.com/redis/docker-library-redis

## Project Structure
- `Dockerfile`: Redis server image build (Alpine).
- `docker-entrypoint.sh`: Upstream entrypoint logic with module loading and permission fixes.
- `redis.conf`: Sample configuration file.
- `../docker-swarm/stacks/redis-stack.yml`: Local swarm stack deployment template.

## Build
```bash
docker image build --no-cache -t kernel528/redis:8.6.4-3.24.1_1 -f Dockerfile .
```

## Run
Standalone server:
```bash
docker container run -d --name redis -p 6379:6379 kernel528/redis:8.6.4-3.24.1_1
```

CLI only:
```bash
docker container run -it --rm kernel528/redis:8.6.4-3.24.1_1 redis-cli --version
```

## Refresh Workflow
1) Update `Dockerfile` base image and Redis source URL/SHA to match the desired upstream release.
2) Update `.drone.yml` tags for the Redis and base-image versions.
3) Build and test locally.
4) Open a PR targeting `8`. The current PR pipeline publishes configured version and build tags, but these are pre-release artifacts and must not be used by downstream images or Swarm.
5) Merge the validated changes through `main`, then create a Git tag from `main`; the tag pipeline publishes `${DRONE_TAG}` and refreshes `latest`.

## Repository Relationships

This independent repository is coordinated by [`docker-workspace`](https://github.com/kernel528/docker-workspace), consumes [`kernel528/alpine`](https://github.com/kernel528/alpine-docker), and publishes `kernel528/redis` for [`docker-swarm`](https://github.com/kernel528/docker-swarm). Publish and verify the Alpine tag before a base refresh. Publish and smoke-test the immutable Redis release before updating `stacks/redis-stack.yml`; deploy the stack separately and preserve the previous tag for rollback.

## CI Tagging (Drone)
- PRs targeting `8` publish configured tags such as `8`, `8.6.4`, and `8.6.4-3.24.1_1`.
- This PR behavior is retained for current CI compatibility; release-looking PR tags are not release-eligible until the merged `main` commit receives a GitHub tag/release.
- `main` branch pushes test the existing `latest` image; they do not publish it.
- Git tags publish `${DRONE_TAG}` and `latest`.
