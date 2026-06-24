FROM debian:trixie-20240211-slim AS build
WORKDIR /src
RUN apt-get update && apt-get install -y git build-essential autoconf libpcre2-dev zlib1g-dev libpq-dev libgeoip-dev python3 python3-dev wget
RUN git clone --depth=1 --branch Angie-1.11.8      https://github.com/webserver-llc/angie.git                  build

WORKDIR /src/build
RUN git clone --depth=1 --branch v0.3.4           https://github.com/vision5/ngx_devel_kit.git                ngx_devel_kit
RUN git clone --depth=1 --branch pcre2-10.47      https://github.com/PCRE2Project/pcre2.git --recurse-submodules pcre2
RUN git clone --depth=1 --branch openssl-3.6.3    https://github.com/openssl/openssl.git                      openssl
RUN git clone --depth=1 --branch v1.3.2           https://github.com/madler/zlib.git                          zlib

RUN git clone --depth=1 --branch v0.65            https://github.com/openresty/echo-nginx-module.git          echo-nginx-module
RUN git clone --depth=1 --branch v0.34            https://github.com/openresty/set-misc-nginx-module.git      set-misc-nginx-module
RUN git clone --depth=1 --branch v0.40            https://github.com/openresty/headers-more-nginx-module.git  headers-more-nginx-module
RUN git clone --depth=1 --branch v0.07            https://github.com/openresty/xss-nginx-module.git           xss-nginx-module
RUN git clone --depth=1 --branch v0.4.0           https://github.com/yaoweibin/nginx_upstream_check_module.git check_module
WORKDIR /src/build

RUN ./configure \
  --build=badsysadm_openresty_build \
  --builddir=$(pwd)/buildbadsysadm \
  --prefix= \
  --sbin-path=/usr/sbin/angie \
  --modules-path=/usr/lib/modules \
  --conf-path=/etc/angie/angie.conf \
  --error-log-path=/var/log/angie/error.log \
  --http-log-path=/var/log/angie/accept.log \
  --pid-path=/run/angie/angie.pid \
  --lock-path=/run/angie/angie.lock \
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
  --with-http_v3_module \
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
  --with-pcre=$(pwd)/pcre2 \
  --with-pcre-jit \
  --add-module=$(pwd)/ngx_devel_kit \
  --add-module=$(pwd)/echo-nginx-module \
  --add-module=$(pwd)/set-misc-nginx-module \
  --add-module=$(pwd)/headers-more-nginx-module \
  --add-module=$(pwd)/xss-nginx-module \
  --add-module=$(pwd)/check_module \
  --with-openssl=$(pwd)/openssl \
  --with-openssl-opt="no-shared no-dso no-tests" \
  --with-compat
  

RUN make -j 1
RUN make install DESTDIR=/tmp/root
WORKDIR /tmp/root
RUN mkdir -p lib64 usr/lib tmp var/log/angie
RUN cp -v   /lib64/ld-linux-x86-64.so.2                                            -t lib64
RUN ldd usr/sbin/angie  | awk '/=>/ {print $3}' | xargs cp -vf --copy-contents     -t usr/lib
RUN echo "nobody:x:65534:65534:System user; nobody:/var/empty:/sbin/nologin" > etc/passwd && echo "nogroup:x:65534:" > etc/group
RUN cd ./etc && ln -s ./angie ./nginx && cd ./angie && ln -s angie.conf nginx.conf && cd ../.. && cd var/log && ln -s ./angie ./nginx
RUN cp -v /etc/os-release etc/os-release
COPY angie.service etc/systemd/system/angie.service

FROM scratch
COPY --from=build /tmp/root /
CMD ["/usr/sbin/angie"]
