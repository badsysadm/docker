ARG VERSION=4.0.7

FROM oci.badsysadm.local:80/dep/utils/procps:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/procps

RUN find . -type f \( \
        -name "configure" \
        -o -name "Makefile.in" \
        -o -name "aclocal.m4" \
        -o -name "config.h.in" \
    \) -exec touch {} +

RUN mkdir -p /src/static-libs && \
    cp \
        /usr/lib/x86_64-linux-gnu/libncurses.a \
        /usr/lib/x86_64-linux-gnu/libncursesw.a \
        /usr/lib/x86_64-linux-gnu/libtinfo.a \
        /usr/lib/x86_64-linux-gnu/libm.a \
        /src/static-libs/

RUN PKG_CONFIG="pkg-config --static" \
    LDFLAGS="-static-libgcc -L/src/static-libs -Wl,--as-needed" \
    ./configure \
        --prefix=/usr \
        --libdir=/usr/lib/x86_64-linux-gnu \
        --enable-static \
        --disable-shared \
        --disable-nls \
        --disable-libselinux \
        --without-systemd \
        --disable-numa \
        --enable-watch8bit \
        --enable-skill \
        --enable-sigwinch

RUN make -j$(nproc) \
    LDFLAGS="-static-libgcc -L/src/static-libs -Wl,--as-needed"

RUN make install DESTDIR=/src/target

RUN rm -rf \
        /src/target/usr/share/doc \
        /src/target/usr/share/man \
        /src/target/usr/share/info \
        /src/target/usr/share/locale

FROM scratch AS bundle
LABEL org.opencontainers.image.title="procps"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="procps-ng process and system utilities"

COPY --from=build /src/target/ /target/
