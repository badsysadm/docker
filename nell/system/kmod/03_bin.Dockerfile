ARG VERSION=34.2

FROM oci.badsysadm.local:80/dep/system/kmod:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/kmod

RUN meson setup build \
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
    -Dc_link_args="-static-libgcc -Wl,-Bstatic /usr/lib/x86_64-linux-gnu/libzstd.a /usr/lib/x86_64-linux-gnu/liblzma.a /usr/lib/x86_64-linux-gnu/libz.a /usr/lib/x86_64-linux-gnu/libcrypto.a -pthread -Wl,-Bdynamic"

RUN ninja -C build
RUN DESTDIR=/src/target ninja -C build install

RUN cd /src/target/bin && \
    ln -sf kmod lsmod && \
    ln -sf kmod modprobe && \
    ln -sf kmod insmod && \
    ln -sf kmod rmmod && \
    ln -sf kmod depmod && \
    ln -sf kmod modinfo

RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info /src/target/usr/share/doc

FROM scratch AS bundle
LABEL org.opencontainers.image.title="kmod"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="kernel module tools"
COPY --from=build /src/target/ /target/
