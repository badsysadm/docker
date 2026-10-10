ARG VERSION=8.2608.0

FROM oci.badsysadm.local:80/dep/system/rsyslog:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/rsyslog

RUN find . -type f \( \
        -name "configure" \
        -o -name "Makefile.in" \
        -o -name "aclocal.m4" \
        -o -name "config.h.in" \
    \) -exec touch {} +

# CivetWeb is required by rsyslog imhttp as a PIC static archive.
RUN make -C /src/civetweb lib \
        WITH_CFLAGS="-I/usr/local/include -DNO_SSL_DL" && \
    install -Dm644 \
        /src/civetweb/include/civetweb.h \
        /usr/local/include/civetweb.h

RUN cd /src/zlib && \
    CFLAGS="-O2 -fPIC" ./configure \
        --static \
        --prefix=/usr/local/static && \
    make -j$(nproc) && \
    make install

RUN make -C /src/zstd/lib libzstd.a \
        CFLAGS="-O2 -fPIC" && \
    make -C /src/zstd/lib \
        PREFIX=/usr/local/static \
        install-static install-pc install-includes

RUN find /src/apr /src/apr-util /src/libxcrypt -type f \( \
        -name "configure" \
        -o -name "Makefile.in" \
        -o -name "aclocal.m4" \
        -o -name "config.h.in" \
    \) -exec touch {} +

RUN cd /src/libxcrypt && \
    CFLAGS="-O2 -fPIC" \
    ./configure \
        --prefix=/usr/local/static \
        --disable-shared \
        --enable-static && \
    make -j$(nproc) && \
    make install

RUN cd /src/apr && \
    CFLAGS="-O2 -fPIC" \
    CPPFLAGS="-I/usr/local/static/include" \
    LDFLAGS="-L/usr/local/static/lib" \
    LIBS="-lcrypt" \
    ./configure \
        --prefix=/usr/local/static \
        --disable-shared \
        --enable-static && \
    make -j$(nproc) && \
    make install

RUN cd /src/apr-util && \
    CFLAGS="-O2 -fPIC" \
    CPPFLAGS="-I/usr/local/static/include" \
    LDFLAGS="-L/usr/local/static/lib" \
    LIBS="-lcrypt" \
    ./configure \
        --prefix=/usr/local/static \
        --with-apr=/usr/local/static \
        --with-expat=/usr \
        --disable-shared \
        --enable-static && \
    make -j$(nproc) && \
    make install

RUN find /src/libfastjson -type f \( \
        -name "configure" \
        -o -name "Makefile.in" \
        -o -name "aclocal.m4" \
        -o -name "config.h.in" \
    \) -exec touch {} +

RUN cd /src/libfastjson && \
    CFLAGS="-O2 -fPIC" \
    ./configure \
        --disable-shared \
        --enable-static && \
    make -j$(nproc)

RUN cd /src/curl && \
    PKG_CONFIG="pkg-config --static" \
    PKG_CONFIG_PATH="/usr/local/static/lib/pkgconfig:/usr/local/lib64/pkgconfig" \
    CFLAGS="-O2 -fPIC" \
    CPPFLAGS="-I/usr/local/include" \
    LDFLAGS="-L/usr/local/lib64 -L/usr/local/static/lib" \
    LIBS="-lssl -lcrypto -lz -lzstd" \
    ./configure \
        --prefix=/usr/local/curl \
        --disable-shared \
        --enable-static \
        --enable-http \
        --disable-ftp \
        --disable-file \
        --disable-ipfs \
        --disable-ldap \
        --disable-ldaps \
        --disable-rtsp \
        --disable-dict \
        --disable-telnet \
        --disable-tftp \
        --disable-pop3 \
        --disable-imap \
        --disable-smb \
        --disable-smtp \
        --disable-gopher \
        --disable-mqtt \
        --disable-manual \
        --disable-docs \
        --without-libpsl \
        --without-libgsasl \
        --without-librtmp \
        --without-libidn2 \
        --without-nghttp2 \
        --without-ngtcp2 \
        --without-nghttp3 \
        --without-quiche \
        --without-msh3 \
        --without-libuv \
        --without-brotli \
        --without-zstd \
        --with-openssl=/usr/local \
        --with-zlib=/usr/local/static && \
    make -j$(nproc) && \
    make install && \
    rm -f /usr/local/curl/lib/libcurl.la

RUN mkdir -p /src/static-libs && \
    cp \
        /src/civetweb/libcivetweb.a \
        /usr/local/static/lib/libz.a \
        /usr/local/static/lib/libzstd.a \
        /usr/lib/x86_64-linux-gnu/libestr.a \
        /src/libfastjson/.libs/libfastjson.a \
        /usr/local/static/lib/libaprutil-1.a \
        /usr/local/static/lib/libapr-1.a \
        /usr/local/static/lib/libcrypt.a \
        /src/static-libs/

RUN PKG_CONFIG="pkg-config --static" \
    PKG_CONFIG_PATH="/usr/local/static/lib/pkgconfig:/usr/local/curl/lib/pkgconfig:/usr/local/lib64/pkgconfig" \
    APU_CFLAGS="$(/usr/local/static/bin/apu-1-config --includes)" \
    APU_LIBS="/src/static-libs/libaprutil-1.a /src/static-libs/libapr-1.a /src/static-libs/libcrypt.a" \
    CFLAGS="-I/usr/local/curl/include -I/usr/local/include" \
    CPPFLAGS="-I/usr/local/curl/include -I/usr/local/include" \
    LDFLAGS="-L/usr/local/static/lib -L/usr/local/curl/lib -L/src/static-libs -L/usr/local/lib64 -Wl,--as-needed" \
    LIBS="-lssl -lcrypto -lz -lzstd" \
    ./configure \
        --prefix=/usr \
        --sbindir=/usr/sbin \
        --libdir=/usr/lib/x86_64-linux-gnu \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --disable-libsystemd \
        --disable-imjournal \
        --disable-relp \
        --disable-rfc3195 \
        --disable-omruleset \
        --disable-libyaml \
        --disable-uuid \
        --disable-libgcrypt \
        --disable-liblogging-stdlog \
        --disable-fmhttp \
        --disable-fmhash \
        --disable-mmleefparse \
        --enable-imfile \
        --enable-imkubernetes \
        --enable-imhttp \
        --enable-omhttp \
        --disable-omotel \
        --disable-impstats-push \
        --disable-testbench \
        --disable-default-tests \
        --disable-imtcp-tests \
        --disable-imfile-tests \
        --disable-gnutls-tests \
        --disable-generate-man-pages

RUN make -j$(nproc)

RUN make install DESTDIR=/src/target

RUN install -Dm644 \
        debian/rsyslog.service \
        /src/target/usr/lib/systemd/system/rsyslog.service && \
    install -d -m755 \
        /src/target/etc/rsyslog.d \
        /src/target/var/lib/rsyslog

RUN find /src/target -type f -name '*.la' -delete && \
    rm -rf \
        /src/target/usr/share/doc \
        /src/target/usr/share/man \
        /src/target/usr/share/info \
        /src/target/usr/share/locale

FROM scratch AS bundle
LABEL org.opencontainers.image.title="rsyslog"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="system and network logging daemon"

COPY --from=build /src/target/ /target/
