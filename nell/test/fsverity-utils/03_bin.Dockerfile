ARG VERSION=1.7

FROM oci.badsysadm.local:80/dep/test/fsverity-utils:${VERSION} AS build
ARG VERSION

WORKDIR /src/fsverity-utils

# Build the upstream CLI together with both library variants.
# Link crypto/compression dependencies statically, leaving libc dynamic.
RUN make -j$(nproc) \
    PREFIX=/usr LIBDIR=/usr/lib PKGCONF=false \
    LDFLAGS="-static-libgcc -L/usr/lib -L/usr/lib64" \
    LDLIBS="-Wl,-Bstatic -lcrypto -lz -lzstd -Wl,-Bdynamic"

RUN make install \
    PREFIX=/usr LIBDIR=/usr/lib DESTDIR=/src/target \
    PKGCONF=false \
    LDFLAGS="-static-libgcc -L/usr/lib -L/usr/lib64" \
    LDLIBS="-Wl,-Bstatic -lcrypto -lz -lzstd -Wl,-Bdynamic" && \
    rm -rf /src/target/usr/share/man && \
    test -f /src/target/usr/bin/fsverity && \
    test -f /src/target/usr/lib/libfsverity.a && \
    test -f /src/target/usr/lib/libfsverity.so.0 && \
    test -L /src/target/usr/lib/libfsverity.so && \
    test -f /src/target/usr/include/libfsverity.h && \
    test -f /src/target/usr/lib/pkgconfig/libfsverity.pc

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="fsverity-utils"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="fs-verity command-line utility and libfsverity"
COPY --from=build /src/target/ /target/
