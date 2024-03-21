FROM wmx-public.gitlab.yandexcloud.net:5050/wmx-public/container-images/node:4.6 AS wallarm
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get purge -y logrotate
RUN sed 's/buster/bullseye/g' -i /etc/apt/sources.list.d/webmonitorx-node.list && \
    echo 'deb http://deb.debian.org/debian bullseye main non-free contrib' > /etc/apt/sources.list
RUN apt-get update -y  && apt-get full-upgrade -y && apt-get install -y libpq-dev libssl-dev libpcre2-dev zlib1g-dev libpq-dev libgeoip-dev

FROM wallarm AS build
WORKDIR /src
RUN apt-get update && apt-get install -y git build-essential autoconf libssl-dev libpcre2-dev zlib1g-dev libpq-dev libgeoip-dev python3 python3-dev wget
RUN rm -rfv /var/lock
#openjdk-23-jdk-headless python3 python3-dev wget
RUN wget  https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox -O /usr/sbin/busybox && chmod +x /usr/sbin/busybox
ARG NGINX_VERSION="1.18.0"
#ARG NGINX_VERSION="1.25.4"
RUN wget -c http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -O nginx.tar.gz && tar -zxf nginx.tar.gz && mv nginx-${NGINX_VERSION} build
RUN git clone --depth=1 --branch v2.1-20231117    https://github.com/openresty/luajit2.git                    build/LuaJIT

WORKDIR /src/build/LuaJIT
RUN make && make install -e PREFIX= && make install -e DESTDIR=$(pwd)/build -e PREFIX=

WORKDIR /src/build
RUN git clone --depth=1 --branch v0.3.3           https://github.com/vision5/ngx_devel_kit.git                ngx_devel_kit
RUN git clone --depth=1 --branch pcre2-10.43      https://github.com/PCRE2Project/pcre2.git                   pcre2
RUN git clone --depth=1 --branch master           https://github.com/luvit/pcre.git                           pcre
RUN git clone --depth=1 --branch openssl-3.2.1    https://github.com/openssl/openssl.git                      openssl
RUN git clone --depth=1 --branch v1.3.1           https://github.com/madler/zlib.git                          zlib
RUN git clone --depth=1 --branch v0.10.26         https://github.com/openresty/lua-nginx-module.git           lua-nginx-module
RUN git clone --depth=1 --branch v0.63            https://github.com/openresty/echo-nginx-module.git          echo-nginx-module
RUN git clone --depth=1 --branch v0.33            https://github.com/openresty/set-misc-nginx-module.git      set-misc-nginx-module
RUN git clone --depth=1 --branch v0.07            https://github.com/openresty/lua-upstream-nginx-module.git  lua-upstream-nginx-module
RUN git clone --depth=1 --branch v0.37            https://github.com/openresty/headers-more-nginx-module.git  headers-more-nginx-module
RUN git clone --depth=1 --branch v0.03            https://github.com/openresty/lua-ssl-nginx-module.git       lua-ssl-nginx-module
RUN git clone --depth=1 --branch v0.06            https://github.com/openresty/xss-nginx-module.git           xss-nginx-module
RUN git clone --depth=1 --branch 1.0              https://github.com/openresty/ngx_postgres.git               ngx_postgres
RUN git clone --depth=1 --branch v0.6.0           https://github.com/nginx-clojure/nginx-clojure.git          nginx-clojure
#RUN git clone --depth=1 --branch v0.2.0           https://github.com/arut/nginx-python-module.git             nginx-python
RUN git clone --depth=1 --branch v0.4.0           https://github.com/yaoweibin/nginx_upstream_check_module.git check_module
RUN git clone --depth=1 --branch v0.2.2           https://github.com/vozlt/nginx-module-vts.git               nginx-module-vts
WORKDIR /src/build
ENV LUAJIT_LIB=./LuaJIT/build/lib/ LUAJIT_INC=./LuaJIT/build/include/luajit-2.1/ DESTDIR="/tmp/root"

RUN ./configure \
  --build=badsysadm_openresty_build \
  --builddir=$(pwd)/buildbadsysadm \
  --prefix=/usr/lib/nginx \
  --sbin-path=/usr/sbin/nginx \
  --modules-path=/usr/lib/nginx/modules \
  --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/accept.log \
  --pid-path=/run/nginx/nginx.pid \
  --lock-path=/run/nginx/nginx.lock \
  --http-client-body-temp-path=/tmp/client-body \
  --http-proxy-temp-path=/tmp/proxy \
  --http-fastcgi-temp-path=/tmp/fastcgi \
  --http-uwsgi-temp-path=/tmp/uwsgi \
  --http-scgi-temp-path=/tmp/scgi \
  --with-threads \
  --with-file-aio \
  --with-debug \
  --with-http_addition_module \
  --with-http_auth_request_module \
  --with-http_degradation_module \
  --with-http_flv_module \
  --with-http_geoip_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_mp4_module \
  --with-http_random_index_module \
  --with-http_realip_module \
  --with-http_secure_link_module \
  --with-http_ssl_module \
  --with-http_stub_status_module \
  --with-http_sub_module \
  --with-http_v2_module \
#  --with-http_v3_module \
  --without-http_fastcgi_module \
  --without-http_memcached_module \
  --without-http_scgi_module \
  --with-stream \
  --with-stream_geoip_module \
  --with-stream_realip_module \
  --with-stream_ssl_module \
  --with-stream_ssl_preread_module \
  --with-mail \
  --with-mail_ssl_module \
  --with-zlib=$(pwd)/zlib \
#  --without-pcre2 \
  --with-pcre=$(pwd)/pcre \
  --with-pcre-jit \
  --add-module=$(pwd)/ngx_devel_kit \
  --add-module=$(pwd)/lua-nginx-module \
  --add-module=$(pwd)/echo-nginx-module \
  --add-module=$(pwd)/set-misc-nginx-module \
  --add-module=$(pwd)/lua-upstream-nginx-module \
  --add-module=$(pwd)/headers-more-nginx-module \
  --add-module=$(pwd)/xss-nginx-module \
  --add-module=$(pwd)/ngx_postgres \
#  --add-module=$(pwd)/nginx-clojure/src/c \
#  --add-module=$(pwd)/nginx-python \
  --add-module=$(pwd)/check_module \
#  --add-module=$(pwd)/nginx-module-vts \
#  --with-openssl=$(pwd)/openssl \
  --with-compat

RUN make -j 4
RUN make install
#WORKDIR /tmp/root
WORKDIR $DESTDIR
RUN mkdir -p lib64 usr/lib tmp var/log/nginx
RUN cp -v   /lib64/ld-linux-x86-64.so.2                                            -t lib64
RUN ldd usr/sbin/nginx  | awk '/=>/ {print $3}' | xargs cp -vf --copy-contents     -t usr/lib
RUN echo "nobody:x:65534:65534:System user; nobody:/var/empty:/sbin/nologin"        > etc/passwd && \
    echo "nogroup:x:65534:"                                                         > etc/group
RUN cp -v /etc/os-release etc/os-release
COPY nginx.service etc/systemd/system/nginx.service

FROM debian:trixie-20240211-slim AS lua
WORKDIR /src
RUN apt-get update -y && apt-get install -y git make
RUN git clone --depth=1 --branch v0.1.28          https://github.com/openresty/lua-resty-core.git                  lua-resty-core
RUN git clone --depth=1 --branch v0.13            https://github.com/openresty/lua-resty-lrucache.git              lua-resty-lrucache
RUN git clone --depth=1 --branch v0.15            https://github.com/openresty/lua-resty-string.git                lua-resty-string
RUN git clone --depth=1 --branch v0.11            https://github.com/openresty/lua-resty-upload.git                lua-resty-upload
RUN git clone --depth=1 --branch v0.11            https://github.com/openresty/lua-resty-websocket.git             lua-resty-websocket
RUN git clone --depth=1 --branch v0.09            https://github.com/openresty/lua-resty-limit-traffic.git         lua-resty-limit-traffic
RUN git clone --depth=1 --branch v0.09            https://github.com/openresty/lua-resty-lock.git                  lua-resty-lock
RUN git clone --depth=1 --branch v0.17            https://github.com/openresty/lua-resty-memcached.git             lua-resty-memcached
RUN git clone --depth=1 --branch v0.08            https://github.com/openresty/lua-resty-upstream-healthcheck.git  lua-resty-healthcheck
RUN git clone --depth=1 --branch v0.27            https://github.com/openresty/lua-resty-mysql.git                 lua-resty-mysql
ENV LUA_LIB_DIR="/usr/local/share/lua/5.1"
RUN for folder in $(ls); do cd "/src/$folder"; make install; done
RUN git clone --depth=1 --branch v2.0             https://github.com/bungle/lua-resty-template.git                 lua-resty-template
RUN cp -rfv ./lua-resty-template/lib/resty/* "$LUA_LIB_DIR/"

FROM wallarm
COPY --from=build /src/build/LuaJIT/build/ /
COPY --from=build /tmp/root/usr/sbin/nginx /usr/sbin/
COPY --from=lua /usr/local/share/lua/5.1/ /usr/local/share/lua/5.1/
RUN apt-get update -y && apt-get upgrade -y
RUN rm -rfv ls /etc/nginx/modules-enabled/50-mod-http-echo.conf /etc/nginx/modules-enabled/50-mod-http-geoip.conf /etc/nginx/modules-enabled/50-mod-mail.conf /etc/nginx/modules-enabled/50-mod-stream.conf /etc/nginx/modules-enabled/70-mod-stream-geoip.conf
RUN chmod 777 /var/lib/wallarm-tarantool -R
COPY wallarm.service wallarm-antibotapiextractor.service wallarm-collectd.service wallarm-registernode.service wallarm-tarantool.service wallarm-syncnode.service wallarm-iplists.service wallarm-export-metrics.service wallarm-export-environments.service wallarm-iplists-source.service wallarm-syncmarkers.service wallarm-export-attacks.service wallarm-export-counters.service wallarm-brute-detect.service wallarm-weak-jwt-detect.service /etc/systemd/system/
RUN mkdir -p /var/lib/wallarm-collectd/
COPY --chmod=555 init-portable /usr/local/bin/
