ARG VERSION=4.8.33

FROM oci.badsysadm.local:80/dep/usr/mc:${VERSION} AS build
ARG VERSION

WORKDIR /src/mc

RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
    GLIB_LIBDIR=/usr/local/lib \
    ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --with-screen=ncursesw \
    --with-glib-static \
    --without-gpm-mouse \
    --without-x \
    --disable-nls \
    --disable-dependency-tracking \
    CPPFLAGS="-I/usr/local/include" \
    LDFLAGS="-L/usr/local/lib -static-libgcc" \
    LIBS="-Wl,-Bstatic -lglib-2.0 -le2p -lpcre2-8 -lffi -lz -lm -Wl,-Bdynamic"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc \
    /src/target/usr/share/gtk-doc

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="Midnight Commander"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Midnight Commander terminal file manager"
COPY --from=build /src/target/ /target/
