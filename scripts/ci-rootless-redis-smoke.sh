#!/usr/bin/env sh
set -eu

: "${DRONE_BUILD_NUMBER:?Drone build number is required}"
: "${DRONE_COMMIT_SHA:?Drone commit SHA is required}"

image="localhost/redis-ci:${DRONE_BUILD_NUMBER}-${DRONE_COMMIT_SHA}"
base_ref=$(awk '$1 == "FROM" && $2 ~ /^kernel528\/alpine:/ { print $2; exit }' Dockerfile)
base_tag=${base_ref##*:}
expected_alpine=${base_tag%_*}
download_url=$(awk '$1 == "ARG" && $2 ~ /^REDIS_DOWNLOAD_URL=/ { sub(/^REDIS_DOWNLOAD_URL=/, "", $2); print $2; exit }' Dockerfile)
redis_version=${download_url##*/tags/}
redis_version=${redis_version%.tar.gz}

if [ -z "$base_tag" ] || [ -z "$expected_alpine" ] || [ -z "$redis_version" ]; then
  printf '%s\n' 'Could not determine the pinned Alpine base or Redis version.' >&2
  exit 1
fi

cleanup() {
  rc=$?
  trap - EXIT
  if docker image inspect "$image" >/dev/null 2>&1; then
    docker image rm --no-prune "$image" || rc=1
  fi
  exit "$rc"
}
trap cleanup EXIT

docker build --pull --no-cache --tag "$image" .
image_id=$(docker image inspect --format '{{.Id}}' "$image")
printf 'Rootless Redis image ID: %s\n' "$image_id"
scripts/ci-smoke-redis-image.sh "$image_id" "$expected_alpine" "$redis_version"
