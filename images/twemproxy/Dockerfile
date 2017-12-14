FROM alpine:3.7

LABEL maintainer="Jimmy Lu <gn00023040@gmail.com>"

ARG TWEMPROXY_VERSION=0.4.1

ENV DI_VERSION=1.2.0 \
    DI_SHA=81231da1cd074fdc81af62789fead8641ef3f24b6b07366a1c34e5b059faf363

COPY files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY files/twemproxy.yaml /etc/twemproxy/twemproxy.yaml

RUN set -xe \
    && apk update && apk upgrade \
    && apk add -t .build-deps --no-cache --update g++ libtool make automake curl autoconf \
    && apk add --no-cache supervisor redis \
    && mkdir -p /var/log/supervisor \
    && chmod 0600 /etc/supervisor/conf.d/supervisord.conf \
    && chmod 0600 /etc/twemproxy/twemproxy.yaml \
    && curl -sLo /sbin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DI_VERSION}/dumb-init_${DI_VERSION}_amd64 \
    && echo "$DI_SHA  /sbin/dumb-init" | sha256sum -c - \
    && chmod +x /sbin/dumb-init \
    && curl -sqL https://github.com/twitter/twemproxy/archive/v${TWEMPROXY_VERSION}.tar.gz | tar xzf - \
    && cd twemproxy-${TWEMPROXY_VERSION} \
    && autoreconf -fvi \
    && ./configure --enable-debug=log \
    && make \
    && make install \
    && apk del .build-deps \
    && rm -rf \
          /twemproxy-${TWEMPROXY_VERSION} \
          /var/cache/apk/* \
          /tmp/*

# twemproxy       : 6379
# twemproxy stats : 22222
EXPOSE 6379 22222

CMD ["/sbin/dumb-init", "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
