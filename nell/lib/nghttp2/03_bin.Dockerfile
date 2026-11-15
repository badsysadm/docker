ARG VERSION=1.71.0

FROM oci.badsysadm.local:80/dep/lib/nghttp2:${VERSION} AS build
ARG VERSION

WORKDIR /src/nghttp2

RUN autoreconf -i

RUN CFLAGS="-O2 -fPIC -ffunction-sections -fdata-sections" \
    LDFLAGS="-Wl,--gc-sections -Wl,--exclude-libs,ALL" \
    ./configure \
    --prefix=/usr --libdir=/usr/lib \
    --enable-static --enable-shared --with-pic \
    --enable-lib-only --disable-python-bindings

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target
RUN rm -rf /src/target/usr/share/doc /src/target/usr/share/man /src/target/usr/share/info
RUN rm -f /src/target/usr/lib/*.la

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="nghttp2"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="HTTP/2 library, static and shared"
COPY --from=build /src/target/ /target/
