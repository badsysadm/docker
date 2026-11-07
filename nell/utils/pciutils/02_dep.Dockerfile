ARG VERSION=3.15.0

FROM oci.badsysadm.local:80/src/utils/pciutils:${VERSION} AS src_image
FROM oci.badsysadm.local:80/dep/system/kmod:34.2 AS kmod_build

WORKDIR /src/kmod
RUN PKG_CONFIG_PATH="/usr/local/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig" \
    meson setup build \
    --prefix=/usr \
    --sysconfdir=/etc \
    --bindir=/bin \
    --sbindir=/sbin \
    --libdir=/lib/x86_64-linux-gnu \
    -Ddefault_library=static \
    -Dprefer_static=true \
    -Dzstd=enabled \
    -Dxz=enabled \
    -Dzlib=enabled \
    -Dopenssl=enabled \
    -Dmanpages=false \
    -Dc_args="-I/usr/local/include" \
    -Dc_link_args="-static-libgcc -Wl,-Bstatic /usr/lib/x86_64-linux-gnu/libzstd.a /usr/lib/x86_64-linux-gnu/liblzma.a /usr/lib/x86_64-linux-gnu/libz.a /usr/local/lib64/libcrypto.a -pthread -Wl,-Bdynamic"

RUN ninja -C build

RUN archive="$(find build -name libkmod-internal.a -print -quit)" && \
    shared="$(find build -name libshared.a -print -quit)" && \
    test -n "$archive" && test -n "$shared" && \
    printf 'CREATE /src/libkmod.a\nADDLIB %s\nADDLIB %s\nSAVE\nEND\n' "$archive" "$shared" | ar -M && \
    objcopy \
        --redefine-sym memdup=kmod_memdup \
        --redefine-sym path_make_absolute_cwd=kmod_path_make_absolute_cwd \
        --redefine-sym mkdir_p=kmod_mkdir_p \
        /src/libkmod.a && \
    ranlib /src/libkmod.a

FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=kmod_build /src/libkmod.a \
    /usr/lib/x86_64-linux-gnu/libkmod.a
COPY --from=oci.badsysadm.local:80/bin/system/systemd:261 \
    /target/usr/lib/x86_64-linux-gnu/libudev.a \
    /usr/lib/x86_64-linux-gnu/libudev.a

COPY --from=oci.badsysadm.local:80/bin/lib/zlib:1.3.1 \
    /target/usr/lib/x86_64-linux-gnu/libz.a \
    /usr/lib/x86_64-linux-gnu/libz.a

COPY --from=src_image /src/ /src/
