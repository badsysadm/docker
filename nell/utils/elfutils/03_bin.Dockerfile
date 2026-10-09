ARG VERSION=0.196

FROM oci.badsysadm.local:80/dep/utils/elfutils:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/elfutils

RUN mkdir -p /src/static-libs && \
    cp \
        /usr/lib/x86_64-linux-gnu/libz.a \
        /usr/lib/x86_64-linux-gnu/libbz2.a \
        /usr/lib/x86_64-linux-gnu/liblzma.a \
        /usr/lib/x86_64-linux-gnu/libzstd.a \
        /src/static-libs/ && \
    cp "$(gcc -print-file-name=libstdc++.a)" /src/static-libs/

RUN PKG_CONFIG="pkg-config --static" \
    ./configure \
        --prefix=/usr \
        --libdir=/usr/lib/x86_64-linux-gnu \
        --disable-debuginfod \
        --disable-libdebuginfod \
        --without-libarchive

RUN make -j$(nproc)

RUN make -C src clean

RUN make -j$(nproc) -C src \
    LDFLAGS="-static-libgcc -L/src/static-libs -Wl,--as-needed" \
    'libasm=../libasm/libasm.a' \
    'libelf=../libelf/libelf.a -lz $(zstd_LIBS)' \
    'libdw=../libdw/libdw.a -lz $(zip_LIBS) $(libelf) -ldl -lpthread' \
    'libdebuginfod='

RUN make install DESTDIR=/src/target

RUN rm -rf \
        /src/target/usr/share/doc \
        /src/target/usr/share/man \
        /src/target/usr/share/info

FROM scratch AS bundle
LABEL org.opencontainers.image.title="elfutils"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="ELF and DWARF utilities"

COPY --from=build /src/target/ /target/
