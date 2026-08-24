FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG PAM_VERSION=1.7.2

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential pkg-config gettext \
    ca-certificates wget bison flex \
    meson ninja-build \
    libaudit-dev libcap-ng-dev libdb-dev

RUN mkdir -p /src/pam /src/target && \
    wget -qO- https://github.com/linux-pam/linux-pam/releases/download/v${PAM_VERSION}/Linux-PAM-${PAM_VERSION}.tar.xz | tar -xJf - -C /src/pam --strip-components=1

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
LABEL org.opencontainers.image.version="1.7.2"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Linux-PAM binaries and modules"
COPY --from=build /src/target/ /
