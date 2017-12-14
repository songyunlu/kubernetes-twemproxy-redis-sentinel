FROM alpine:3.7

LABEL maintainer="Jimmy Lu <gn00023040@gmail.com>"

ENV DI_VERSION=1.2.0 \
    DI_SHA=81231da1cd074fdc81af62789fead8641ef3f24b6b07366a1c34e5b059faf363

COPY files/redis-master.conf /redis-master/redis.conf
COPY files/redis-slave.conf /redis-slave/redis.conf
COPY files/run.sh /run.sh

RUN set -ex \
    && apk update && apk upgrade \
	&& apk add --no-cache -t .build-deps curl \
    && apk add --no-cache redis \
    && chmod 0600 /redis-master/redis.conf \
    && chmod 0600 /redis-slave/redis.conf \
    && chmod 0755 /run.sh \
    && curl -sLo /sbin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DI_VERSION}/dumb-init_${DI_VERSION}_amd64 \
    && echo "$DI_SHA  /sbin/dumb-init" | sha256sum -c - \
    && chmod +x /sbin/dumb-init \
    && apk del .build-deps \
    && rm -rf \
          /var/cache/apk/* \
          /tmp/*

EXPOSE 6379 26379

ENTRYPOINT ["/sbin/dumb-init", "sh", "-c" ]

CMD [ "./run.sh" ]
