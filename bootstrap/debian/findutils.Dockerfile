FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG FINDUTILS_VERSION=4.11.0

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential pkg-config gettext \
    ca-certificates wget

RUN mkdir -p /src/findutils /src/target && \
    wget -qO- https://ftp.gnu.org/gnu/findutils/findutils-${FINDUTILS_VERSION}.tar.xz | tar -xJf - -C /src/findutils --strip-components=1

WORKDIR /src/findutils

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --sbindir=/sbin \
    --libdir=/usr/lib64 \
    --disable-nls

RUN make -j$(nproc)
RUN make DESTDIR=/src/target install
RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info

FROM scratch AS bundle
LABEL org.opencontainers.image.title="findutils"
LABEL org.opencontainers.image.version="4.11.0"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU findutils binaries"
COPY --from=build /src/target/ /
