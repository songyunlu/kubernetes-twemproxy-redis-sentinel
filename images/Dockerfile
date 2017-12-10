FROM alpine:3.7

LABEL maintainer="Jimmy Lu <jimmylu@hyvesolutions.com>"

ARG TWEMPROXY_VERSION=0.4.1

COPY files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY files/twemproxy.yaml /etc/twemproxy/conf/twemproxy.yaml

RUN apk add --update g++ libtool make automake curl autoconf supervisor \
    && mkdir -p /var/log/supervisor \
    && curl -qL https://github.com/twitter/twemproxy/archive/v${TWEMPROXY_VERSION}.tar.gz | tar xzf - \
    && cd twemproxy-0.4.1 && autoreconf -fvi && ./configure --enable-debug=log && make && make install \
    && apk del g++ libtool make automake curl autoconf

EXPOSE 6379

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
