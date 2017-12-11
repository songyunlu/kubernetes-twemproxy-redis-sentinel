FROM ruby:2.4.2-alpine3.7

LABEL maintainer="Jimmy Lu <jimmylu@hyvesolutions.com>"

ENV DI_VERSION=1.2.0 \
    DI_SHA=81231da1cd074fdc81af62789fead8641ef3f24b6b07366a1c34e5b059faf363

COPY files/twemproxy.yaml /etc/twemproxy/twemproxy.yaml

RUN set -xe \
    && apk update && apk upgrade \
    && apk add --update --no-cache -t .build-deps g++ make automake autoconf bash curl \
    && chmod 0600 /etc/twemproxy/twemproxy.yaml \
    && curl -sLo /sbin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DI_VERSION}/dumb-init_${DI_VERSION}_amd64 \
    && echo "$DI_SHA  /sbin/dumb-init" | sha256sum -c - \
    && chmod +x /sbin/dumb-init \
    && gem install nutcracker-web -v 0.0.14 \
    && apk del .build-deps \
    && rm -rf \
          /var/cache/apk/* \
          /usr/local/bundle/build_info/* \
          /usr/local/bundle/cache/* \
          /usr/local/bundle/doc/* \
          /usr/local/bundle/extensions/* \
          tmp/*

EXPOSE 9292

CMD ["/sbin/dumb-init", "nutcracker-web", "--config", "/etc/twemproxy/twemproxy.yaml"]
