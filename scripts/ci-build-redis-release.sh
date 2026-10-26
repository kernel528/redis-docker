#!/usr/bin/env sh
set -eu

: "${DRONE_BUILD_NUMBER:?Drone build number is required}"
: "${DRONE_BUILD_EVENT:?Drone build event is required}"
: "${DRONE_TAG:?Release tag is required}"
: "${DRONE_COMMIT_REF:?Git ref is required}"
: "${DRONE_COMMIT_SHA:?Commit SHA is required}"

if [ "$DRONE_BUILD_EVENT" != tag ] || [ "$DRONE_COMMIT_REF" != "refs/tags/$DRONE_TAG" ]; then
  printf '%s\n' 'Redis release builds require their matching Git tag event.' >&2
  exit 1
fi

base_ref=$(awk '$1 == "FROM" && $2 ~ /^kernel528\/alpine:/ { print $2; exit }' Dockerfile)
base_tag=${base_ref##*:}
expected_alpine=${base_tag%_*}
download_url=$(awk '$1 == "ARG" && $2 ~ /^REDIS_DOWNLOAD_URL=/ { sub(/^REDIS_DOWNLOAD_URL=/, "", $2); print $2; exit }' Dockerfile)
redis_version=${download_url##*/tags/}
redis_version=${redis_version%.tar.gz}
release_date=${DRONE_TAG#"${redis_version}-"}
image="localhost/redis-release:${DRONE_BUILD_NUMBER}-${DRONE_COMMIT_SHA}"

case "$DRONE_TAG" in
  "${redis_version}-"*) ;;
  *) printf 'Redis release tag must start with %s-.\n' "$redis_version" >&2; exit 1 ;;
esac
case "$release_date" in
  ??????) ;;
  *) printf 'Redis release tag must end in a six-digit YYMMDD date: %s\n' "$DRONE_TAG" >&2; exit 1 ;;
esac
case "$release_date" in
  *[!0-9]*) printf 'Redis release date must be numeric: %s\n' "$release_date" >&2; exit 1 ;;
esac

attempt=0
until docker info >/dev/null 2>&1; do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge 60 ]; then
    printf '%s\n' 'Docker-in-Docker service did not become ready.' >&2
    exit 1
  fi
  sleep 1
done

docker build --pull --no-cache --tag "$image" .
image_id=$(docker image inspect --format '{{.Id}}' "$image")
printf 'Redis release source commit: %s\n' "$DRONE_COMMIT_SHA"
printf 'Redis release tag: %s\n' "$DRONE_TAG"
printf 'Redis release image ID: %s\n' "$image_id"
scripts/ci-smoke-redis-image.sh "$image_id" "$expected_alpine" "$redis_version"

umask 077
printf '%s\n' "$image_id" > .drone-redis-image-id
printf '%s\n' "$DRONE_TAG" > .drone-redis-release-tag
printf '%s\n' "$DRONE_COMMIT_SHA" > .drone-redis-commit
