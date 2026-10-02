ARG VERSION=20250605

FROM oci.badsysadm.local:80/dep/utils/iputils:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

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
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="IPUtils binaries and tools"
COPY --from=build /src/target/ /target/
