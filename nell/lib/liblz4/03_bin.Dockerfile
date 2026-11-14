ARG VERSION=1.10.0

FROM oci.badsysadm.local:80/dep/lib/liblz4:${VERSION} AS build
ARG VERSION

WORKDIR /src/lz4

RUN make -j$(nproc) lib-release lz4-release \
    CFLAGS="-O2 -fPIC -ffunction-sections -fdata-sections" \
    LDFLAGS="-Wl,-z,relro,-z,now -Wl,--gc-sections"

RUN make -C lib install \
    PREFIX=/usr \
    LIBDIR=/usr/lib \
    DESTDIR=/src/target
RUN make -C programs install \
    PREFIX=/usr \
    DESTDIR=/src/target
RUN rm -rf /src/target/usr/share/man

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="liblz4"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="LZ4 static and shared compression libraries"
COPY --from=build /src/target/ /target/
