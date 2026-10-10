ARG VERSION=2.47

FROM oci.badsysadm.local:80/dep/utils/binutils:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

RUN mkdir -p /src/static-libs /src/build && \
    cp \
        /usr/lib/x86_64-linux-gnu/libz.a \
        /usr/lib/x86_64-linux-gnu/libzstd.a \
        /usr/lib/x86_64-linux-gnu/libjansson.a \
        /src/static-libs/

WORKDIR /src/build

RUN PKG_CONFIG="pkg-config --static" \
    LDFLAGS="-static-libgcc -static-libstdc++ -L/src/static-libs -Wl,--as-needed" \
    /src/binutils/configure \
        --prefix=/usr \
        --libdir=/usr/lib/x86_64-linux-gnu \
        --disable-nls \
        --disable-werror \
        --disable-shared \
        --enable-static \
        --enable-plugins \
        --enable-threads \
        --enable-deterministic-archives \
        --enable-new-dtags \
        --enable-gprofng=yes \
        --with-system-zlib \
        --with-zstd \
        --enable-jansson

RUN make -j$(nproc) \
    LDFLAGS="-static-libgcc -static-libstdc++ -L/src/static-libs -Wl,--as-needed"

RUN make install DESTDIR=/src/target

RUN rm -rf \
        /src/target/usr/share/man \
        /src/target/usr/share/info \
        /src/target/usr/share/doc \
        /src/target/usr/share/locale

FROM scratch AS bundle
LABEL org.opencontainers.image.title="binutils"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU assembler, linker and binary utilities"

COPY --from=build /src/target/ /target/
