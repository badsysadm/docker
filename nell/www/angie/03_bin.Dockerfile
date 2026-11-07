ARG VERSION=1.12.4

FROM oci.badsysadm.local:80/dep/www/angie:${VERSION} AS build
ARG VERSION

WORKDIR /src/angie
RUN ./configure \
    --build=badsysadm_openresty_build \
    --builddir=/src/angie/buildbadsysadm \
    --prefix= \
    --sbin-path=/usr/sbin/angie \
    --modules-path=/usr/lib/modules \
    --conf-path=/etc/angie/angie.conf \
    --error-log-path=/var/log/angie/error.log \
    --http-log-path=/var/log/angie/accept.log \
    --pid-path=/var/run/angie/angie.pid \
    --lock-path=/var/run/angie/angie.lock \
    --http-client-body-temp-path=/tmp/angie/client-body \
    --http-proxy-temp-path=/tmp/angie/proxy \
    --http-fastcgi-temp-path=/tmp/angie/fastcgi \
    --http-uwsgi-temp-path=/tmp/angie/uwsgi \
    --http-scgi-temp-path=/tmp/angie/scgi \
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
    --with-zlib=/src/angie/zlib \
    --with-pcre=/src/angie/pcre2 \
    --with-pcre-jit \
    --add-module=/src/angie/ngx_devel_kit \
    --add-module=/src/angie/echo-nginx-module \
    --add-module=/src/angie/set-misc-nginx-module \
    --add-module=/src/angie/headers-more-nginx-module \
    --add-module=/src/angie/xss-nginx-module \
    --add-module=/src/angie/check_module \
    --with-cc-opt="-I/usr/local/include" \
    --with-ld-opt="-L/usr/local/lib64 -Wl,-Bstatic -lGeoIP /usr/local/lib64/libssl.a /usr/local/lib64/libcrypto.a -lzstd -lz -Wl,-Bdynamic" \
    --with-compat

RUN make -j 1
RUN make install DESTDIR=/src/target

RUN rm -rf /src/target/usr/share/man \
    /src/target/usr/share/doc \
    /src/target/html

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="angie"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Angie HTTP and reverse proxy server"
COPY --from=build /src/target/ /target/
