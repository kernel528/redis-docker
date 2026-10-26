#!/usr/bin/env sh
set -eu

image_id=${1:?Usage: ci-smoke-redis-image.sh <image-id> <alpine-release> <redis-version>}
expected_alpine=${2:?Usage: ci-smoke-redis-image.sh <image-id> <alpine-release> <redis-version>}
expected_redis=${3:?Usage: ci-smoke-redis-image.sh <image-id> <alpine-release> <redis-version>}
container_id=""

cleanup() {
  rc=$?
  trap - EXIT
  if [ -n "$container_id" ]; then
    docker container rm --force "$container_id" >/dev/null || rc=1
  fi
  exit "$rc"
}
trap cleanup EXIT

actual_alpine=$(docker container run --rm "$image_id" cat /etc/alpine-release)
if [ "$actual_alpine" != "$expected_alpine" ]; then
  printf 'Alpine release mismatch: expected %s, got %s\n' "$expected_alpine" "$actual_alpine" >&2
  exit 1
fi

server_version=$(docker container run --rm "$image_id" redis-server --version 2>&1)
case "$server_version" in
  *"v=$expected_redis"*) ;;
  *) printf 'Redis server version mismatch; expected %s, got %s\n' "$expected_redis" "$server_version" >&2; exit 1 ;;
esac

client_version=$(docker container run --rm "$image_id" redis-cli --version 2>&1)
case "$client_version" in
  *"$expected_redis"*) ;;
  *) printf 'Redis CLI version mismatch; expected %s, got %s\n' "$expected_redis" "$client_version" >&2; exit 1 ;;
esac

container_id=$(docker container create "$image_id" redis-server --save "" --appendonly no --dir /tmp --bind 127.0.0.1 --port 6379)
docker container start "$container_id" >/dev/null
attempt=0
until [ "$(docker container exec "$container_id" redis-cli ping 2>/dev/null || true)" = PONG ]; do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge 30 ]; then
    docker container logs "$container_id" >&2 || true
    printf '%s\n' 'Redis did not become ready within 30 seconds.' >&2
    exit 1
  fi
  sleep 1
done

docker container exec "$container_id" redis-cli set ci_smoke_key ok >/dev/null
actual_value=$(docker container exec "$container_id" redis-cli get ci_smoke_key)
if [ "$actual_value" != ok ]; then
  printf 'Redis PING/SET/GET smoke failed: expected ok, got %s\n' "$actual_value" >&2
  exit 1
fi

printf 'Redis smoke checks passed: Alpine %s, Redis %s, PING/SET/GET.\n' \
  "$actual_alpine" "$expected_redis"
