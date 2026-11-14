ARG VERSION=1.0.2

FROM oci.badsysadm.local:80/dep/lib/libnetfilter-log:${VERSION} AS build
ARG VERSION

WORKDIR /src/libnetfilter_log

RUN find . -type f \( -name "configure" -o -name "Makefile.in" -o -name "aclocal.m4" \) -exec touch {} +

RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure \
    --prefix=/usr/local \
    --libdir=/usr/local/lib \
    --enable-static \
    --enable-shared \
    --with-pic \
    --disable-man-pages \
    --disable-html-doc \
    CFLAGS="-O2 -fPIC -flto=auto -D_FORTIFY_SOURCE=3 -fstack-protector-strong -fstack-clash-protection -fcf-protection=full -ftrivial-auto-var-init=zero -ffunction-sections -fdata-sections" \
    LDFLAGS="-flto=auto -Wl,-z,relro,-z,now -Wl,--gc-sections"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target
RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info
RUN rm -f /src/target/usr/local/lib/*.la

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libnetfilter_log"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="libnetfilter_log static and shared libraries"
COPY --from=build /src/target/ /target/
