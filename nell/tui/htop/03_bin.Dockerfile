ARG VERSION=3.5.3

FROM oci.badsysadm.local:80/dep/tui/htop:${VERSION} AS build
ARG VERSION

WORKDIR /src/htop

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --enable-unicode \
    --disable-affinity \
    --enable-hwloc \
    --enable-capabilities \
    --disable-sensors \
    --disable-delayacct \
    --enable-backtrace=unwind-ptrace \
    --with-libunwind=yes \
    --disable-pcp \
    CURSES_CFLAGS="-I/usr/local/include" \
    CURSES_LIBS="-L/usr/local/lib -Wl,-Bstatic -lncursesw -Wl,-Bdynamic" \
    LDFLAGS="-L/usr/local/lib -static-libgcc -no-pie" \
    LIBS="-Wl,-Bstatic -Wl,--start-group -lcap -lhwloc -lnuma -lltdl -lxml2 -lunwind-ptrace -lunwind-generic -lunwind-x86_64 -lunwind -llzma -lz -lm -Wl,--end-group -Wl,-Bdynamic"

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
