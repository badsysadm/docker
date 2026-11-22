ARG VERSION=3.54.1

FROM oci.badsysadm.local:80/dep/lib/sqlite:${VERSION} AS build
ARG VERSION

WORKDIR /src/sqlite

RUN ./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    CFLAGS="-O2 -fPIC -ffunction-sections -fdata-sections" \
    LDFLAGS="-static-libgcc -Wl,--gc-sections"

RUN make -j$(nproc) LDFLAGS.math=-l:libm.a
RUN make install DESTDIR=/src/target
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
