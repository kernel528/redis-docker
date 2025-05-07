FROM kernel528/alpine:3.21.3
MAINTAINER Joe Sanders - copied from https://github.com/goodsmileduck/redis-cli/Dockerfile 

ARG REDIS_VERSION="7.2.4"
ARG REDIS_DOWNLOAD_URL="http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz"

USER root

RUN apk update && apk upgrade \
    && apk add --update --no-cache --virtual build-deps gcc make linux-headers musl-dev tar \
    && wget -O redis.tar.gz "$REDIS_DOWNLOAD_URL" \
    && mkdir -p /usr/src/redis \
    && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
    && rm redis.tar.gz \
    && cd /usr/src/redis; make distclean \
    && make -C /usr/src/redis install redis-cli /usr/bin \
    && rm -r /usr/src/redis \
    && apk del build-deps \
    && rm -rf /var/cache/apk/*

CMD  ["redis-cli"]
