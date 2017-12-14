FROM alpine:3.7

LABEL maintainer="Jimmy Lu <jimmylu@hyvesolutions.com>"

ENV RUBY_MAJOR=2.4 \
    RUBY_VERSION=2.4.2 \
    RUBY_DOWNLOAD_SHA256=748a8980d30141bd1a4124e11745bb105b436fb1890826e0d2b9ea31af27f735 \
    RUBYGEMS_VERSION=2.7.3 \
    BUNDLER_VERSION=1.16.0 \
    GEM_HOME=/usr/local/bundle \
    BUNDLE_PATH="$GEM_HOME" \
	BUNDLE_BIN="$GEM_HOME/bin" \
	BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME" \
    PATH=$BUNDLE_BIN:$PATH \
    DI_VERSION=1.2.0 \
    DI_SHA=81231da1cd074fdc81af62789fead8641ef3f24b6b07366a1c34e5b059faf363


COPY files/twemproxy.yaml /etc/twemproxy/twemproxy.yaml

RUN set -xe \
    && apk update && apk upgrade \
    && mkdir -p /usr/local/etc \
	&& { \
		 echo 'install: --no-document'; \
		 echo 'update: --no-document'; \
	   } >> /usr/local/etc/gemrc \
	&& apk add --no-cache --virtual .ruby-builddeps \
		autoconf \
		bison \
		bzip2 \
		bzip2-dev \
		ca-certificates \
		coreutils \
		dpkg-dev dpkg \
		gcc \
		gdbm-dev \
		glib-dev \
		libc-dev \
		libffi-dev \
		libressl \
		libressl-dev \
		libxml2-dev \
		libxslt-dev \
		linux-headers \
		make \
		ncurses-dev \
		procps \
		readline-dev \
		ruby \
		tar \
		xz \
		yaml-dev \
		zlib-dev \
	&& wget -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz" \
	&& echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum -c - \
	&& mkdir -p /usr/src/ruby \
	&& tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1 \
	&& rm ruby.tar.xz \
	&& cd /usr/src/ruby \
	&& { \
		 echo '#define ENABLE_PATH_CHECK 0'; \
		 echo; \
		 cat file.c; \
	   } > file.c.new \
	&& mv file.c.new file.c \
	&& autoconf \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& export ac_cv_func_isnan=yes ac_cv_func_isinf=yes \
	&& ./configure \
		--build="$gnuArch" \
		--disable-install-doc \
		--enable-shared \
	&& make -j "$(nproc)" \
	&& make install \
	&& runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add --virtual .ruby-rundeps $runDeps \
		bzip2 \
		ca-certificates \
		libffi-dev \
		libressl-dev \
		procps \
		yaml-dev \
		zlib-dev \
	&& cd / \
	&& gem update --system "$RUBYGEMS_VERSION" \
	&& gem install bundler --version "$BUNDLER_VERSION" --force \
    && mkdir -p "$GEM_HOME" "$BUNDLE_BIN" \
	&& chmod 777 "$GEM_HOME" "$BUNDLE_BIN" \
    && apk add --update --no-cache -t .nutcracker-web-build-deps g++ make automake autoconf bash curl \
    && chmod 0600 /etc/twemproxy/twemproxy.yaml \
    && curl -sLo /sbin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DI_VERSION}/dumb-init_${DI_VERSION}_amd64 \
    && echo "$DI_SHA  /sbin/dumb-init" | sha256sum -c - \
    && chmod +x /sbin/dumb-init \
    && gem install nutcracker-web -v 0.0.14 \
	&& apk del .ruby-builddeps .nutcracker-web-build-deps \
    && rm -rf \
	      /usr/src/ruby \
          /var/cache/apk/* \
          /usr/local/bundle/build_info/* \
          /usr/local/bundle/cache/* \
          /usr/local/bundle/doc/* \
          tmp/*

EXPOSE 9292

CMD ["/sbin/dumb-init", "nutcracker-web", "--config", "/etc/twemproxy/twemproxy.yaml"]
