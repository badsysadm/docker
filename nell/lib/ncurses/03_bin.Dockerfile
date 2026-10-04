ARG VERSION=6.6

FROM oci.badsysadm.local:80/dep/lib/ncurses:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/ncurses

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --bindir=/bin \
    --libdir=/lib/x86_64-linux-gnu \
    --without-manpages \
    --without-tests \
    --enable-static \
    --without-shared \
    --without-debug \
    --enable-widec \
    --enable-pc-files \
    --with-pkg-config-libdir=/usr/lib/x86_64-linux-gnu/pkgconfig \
    --enable-ext-colors \
    --enable-ext-mouse \
    CC="gcc -static" \
    LDFLAGS="-static"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN mkdir -p /src/target/lib/x86_64-linux-gnu && \
    cp -a /src/target/usr/lib/x86_64-linux-gnu/* /src/target/lib/x86_64-linux-gnu/ 2>/dev/null || true

RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info /src/target/usr/share/doc

FROM scratch AS bundle
LABEL org.opencontainers.image.title="ncurses"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="ncurses libraries and terminal utilities"
COPY --from=build /src/target/ /target/
