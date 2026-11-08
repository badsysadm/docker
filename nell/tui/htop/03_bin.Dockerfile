ARG VERSION=3.5.3

FROM oci.badsysadm.local:80/dep/tui/htop:${VERSION} AS build
ARG VERSION

WORKDIR /src/htop

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --enable-unicode \
    --enable-affinity \
    --disable-hwloc \
    --disable-capabilities \
    --disable-sensors \
    --disable-delayacct \
    --disable-backtrace \
    --disable-pcp \
    CURSES_CFLAGS="-I/usr/local/include" \
    CURSES_LIBS="-L/usr/local/lib -Wl,-Bstatic -lncursesw -ltinfo -Wl,-Bdynamic" \
    LDFLAGS="-static-libgcc"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target
RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/doc \
    /src/target/usr/share/info \
    /src/target/usr/share/applications \
    /src/target/usr/share/pixmaps \
    /src/target/usr/share/icons

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="htop"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Interactive process viewer"
COPY --from=build /src/target/ /target/
