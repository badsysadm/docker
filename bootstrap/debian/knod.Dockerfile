FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG KMOD_VERSION=v34.2

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential ca-certificates git meson ninja-build \
    pkg-config libzstd-dev liblzma-dev zlib1g-dev libssl-dev

RUN mkdir -p /src /src/target

RUN git clone --single-branch --branch ${KMOD_VERSION} --depth 1 https://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git /src/kmod

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
    -Dc_link_args="-static-libgcc -Wl,-Bstatic /usr/lib/x86_64-linux-gnu/libzstd.a /usr/lib/x86_64-linux-gnu/liblzma.a /usr/lib/x86_64-linux-gnu/libz.a /usr/lib/x86_64-linux-gnu/libcrypto.a -pthread -Wl,-Bdynamic" && \
    ninja -C build && \
    DESTDIR=/src/target ninja -C build install

RUN cd /src/target/bin && \
    ln -sf kmod lsmod && \
    ln -sf kmod modprobe && \
    ln -sf kmod insmod && \
    ln -sf kmod rmmod && \
    ln -sf kmod depmod && \
    ln -sf kmod modinfo

FROM scratch AS bundle
LABEL org.opencontainers.image.title="kmod"
LABEL org.opencontainers.image.version="34.2"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="kernel module tools"
COPY --from=build /src/target/ /
