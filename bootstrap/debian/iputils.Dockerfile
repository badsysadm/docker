FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG IPUTILS_VERSION=20250605

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential pkg-config gettext \
    ca-certificates wget \
    meson ninja-build \
    libcap-dev libidn2-dev libunistring-dev

RUN mkdir -p /src/iputils /src/target && \
    wget -qO- https://github.com/iputils/iputils/archive/refs/tags/${IPUTILS_VERSION}.tar.gz | tar -xzf - -C /src/iputils --strip-components=1

WORKDIR /src/iputils

RUN LDFLAGS="-Wl,-Bstatic -lcap -lidn2 -lunistring -Wl,-Bdynamic" meson setup build \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --sbindir=/sbin \
    --libdir=/usr/lib64 \
    -DBUILD_ARPING=true \
    -DBUILD_CLOCKDIFF=true \
    -DBUILD_PING=true \
    -DBUILD_TRACEPATH=true \
    -DBUILD_MANS=false \
    -DBUILD_HTML_MANS=false \
    -DUSE_GETTEXT=false \
    -DSKIP_TESTS=true

RUN ninja -C build
RUN DESTDIR=/src/target ninja -C build install

FROM scratch AS bundle
LABEL org.opencontainers.image.title="iputils"
LABEL org.opencontainers.image.version="20250605"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="iputils binaries and tools"
COPY --from=build /src/target/ /
