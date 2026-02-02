# Repository Guidelines

## Project Structure & Module Organization
- `Dockerfile` builds the Redis server image from source on Alpine.
- `Dockerfile.arm64` builds a lightweight ARM64 redis-cli image.
- `docker-entrypoint.sh` mirrors upstream entrypoint logic for permissions and module loading.
- `redis.conf` contains a sample configuration.
- `redis-stack.yml` is a local stack example for deployments.

## Build, Test, and Development Commands
- `docker image build --no-cache -t kernel528/redis:8.4.0 -f Dockerfile .` builds the server image locally.
- `docker container run -d --name redis -p 6379:6379 kernel528/redis:8.4.0` runs a local Redis server.
- `docker container run -it --rm kernel528/redis:8.4.0 redis-cli --version` validates the CLI.

## Coding Style & Naming Conventions
- Keep Dockerfiles aligned with upstream `redis/docker-library-redis` structure.
- Use explicit version tags in `.drone.yml` (for example `8.4.0` and `8.4.0-drone-build-<build>-amd64`).
- Shell scripts should remain POSIX `sh` compatible and avoid bash-specific syntax.

## Testing Guidelines
- CI smoke tests run `redis-cli --version` against the published image.
- For local validation, start Redis and run a quick `PING` using `redis-cli`.

## Commit & Pull Request Guidelines
- Use clear version-scoped messages such as `Update Redis to 8.4.0`.
- PRs should mention base image updates, Redis URL/SHA changes, and any CI tag updates.
- Include the exact build and run commands used for verification.

## Release Flow
- Create a version branch (for example `8.4.0`) for validation builds only.
- Merge into `8` to publish versioned tags.
- Merge into `main` to publish `latest`, then create a Git tag for the release.
