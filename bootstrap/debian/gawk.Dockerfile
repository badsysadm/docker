FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG GAWK_VERSION=5.4.1

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential pkg-config gettext \
    ca-certificates wget

RUN mkdir -p /src/gawk /src/target && \
    wget -qO- https://ftp.gnu.org/gnu/gawk/gawk-${GAWK_VERSION}.tar.xz | tar -xJf - -C /src/gawk --strip-components=1

WORKDIR /src/gawk

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
LABEL org.opencontainers.image.title="gawk"
LABEL org.opencontainers.image.version="5.4.1"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU awk binary and utilities"
COPY --from=build /src/target/ /
