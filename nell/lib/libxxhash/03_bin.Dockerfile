ARG VERSION=0.8.3

FROM oci.badsysadm.local:80/dep/lib/libxxhash:${VERSION} AS build
ARG VERSION

WORKDIR /src/xxhash

RUN make -j$(nproc) lib \
    CFLAGS="-O2 -fPIC -ffunction-sections -fdata-sections" \
    LDFLAGS="-Wl,-z,relro,-z,now -Wl,--gc-sections"

RUN make \
    PREFIX=/usr \
    LIBDIR=/usr/lib \
    DESTDIR=/src/target \
    install_libxxhash.a install_libxxhash install_libxxhash.includes install_libxxhash.pc

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libxxhash"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="xxHash static and shared hashing libraries"
COPY --from=build /src/target/ /target/
