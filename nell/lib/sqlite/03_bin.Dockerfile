ARG VERSION=3.54.1

FROM oci.badsysadm.local:80/dep/lib/sqlite:${VERSION} AS build
ARG VERSION

WORKDIR /src/sqlite

RUN ./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --disable-math \
    CFLAGS="-O2 -fPIC -ffunction-sections -fdata-sections" \
    LDFLAGS="-static-libgcc -Wl,--gc-sections"

RUN make -j$(nproc) libsqlite3.a libsqlite3.so
RUN make -j$(nproc) sqlite3 \
    CFLAGS="-O2 -fno-pie -fno-math-errno -fno-trapping-math -ffunction-sections -fdata-sections" \
    LDFLAGS.configure="-static-libgcc -no-pie -Wl,--gc-sections" \
    LDFLAGS.math=
RUN make install-lib install-dll install-headers install-pc install-shell-0 DESTDIR=/src/target
RUN rm -rf \
    /src/target/usr/share/doc \
    /src/target/usr/share/man \
    /src/target/usr/share/info
RUN rm -f /src/target/usr/lib/*.la

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="sqlite"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="SQLite library and command-line shell"
COPY --from=build /src/target/ /target/
