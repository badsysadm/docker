ARG VERSION=1.7.2

FROM oci.badsysadm.local:80/dep/system/pam:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/pam

RUN LDFLAGS="-Wl,-Bstatic -laudit -lcap-ng -Wl,-Bdynamic" meson setup build \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --sbindir=/sbin \
    --libdir=/usr/lib64 \
    -Dselinux=disabled \
    -Dopenssl=disabled \
    -Ddocs=disabled \
    -Di18n=disabled \
    -Dexamples=false \
    -Dxtests=false

RUN ninja -C build
RUN DESTDIR=/src/target ninja -C build install

FROM scratch AS bundle
LABEL org.opencontainers.image.title="pam"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Linux-PAM binaries and modules"

COPY --from=build /src/target/ /target/
