#!/usr/bin/env sh
set -eu

: "${DRONE_BUILD_NUMBER:?Drone build number is required}"
: "${DRONE_BUILD_EVENT:?Drone build event is required}"
: "${DRONE_BRANCH:?Drone branch is required}"
: "${DRONE_COMMIT_SHA:?Drone commit SHA is required}"

if [ "$DRONE_BUILD_EVENT" != push ] || [ "$DRONE_BRANCH" != 8 ]; then
  printf '%s\n' 'Redis candidates are allowed only on pushes to the 8 maintenance branch.' >&2
  exit 1
fi

base_ref=$(awk '$1 == "FROM" && $2 ~ /^kernel528\/alpine:/ { print $2; exit }' Dockerfile)
base_tag=${base_ref##*:}
expected_alpine=${base_tag%_*}
download_url=$(awk '$1 == "ARG" && $2 ~ /^REDIS_DOWNLOAD_URL=/ { sub(/^REDIS_DOWNLOAD_URL=/, "", $2); print $2; exit }' Dockerfile)
redis_version=${download_url##*/tags/}
redis_version=${redis_version%.tar.gz}
image="localhost/redis-candidate:${DRONE_BUILD_NUMBER}-${DRONE_COMMIT_SHA}"
candidate_tag="${redis_version}-${base_tag}-drone-build-${DRONE_BUILD_NUMBER}-amd64"

if [ -z "$base_tag" ] || [ -z "$expected_alpine" ] || [ -z "$redis_version" ]; then
  printf '%s\n' 'Could not determine the pinned Alpine base or Redis version.' >&2
  exit 1
fi

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
printf 'Redis candidate image ID: %s\n' "$image_id"
printf 'Redis candidate tag after publish: %s\n' "$candidate_tag"
scripts/ci-smoke-redis-image.sh "$image_id" "$expected_alpine" "$redis_version"

umask 077
printf '%s\n' "$image_id" > .drone-redis-image-id
printf '%s\n' "$candidate_tag" > .drone-redis-image-tag
printf '%s\n' "$DRONE_COMMIT_SHA" > .drone-redis-commit
