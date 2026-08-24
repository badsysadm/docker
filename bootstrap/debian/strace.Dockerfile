FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG STRACE_VERSION=7.2

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential pkg-config gettext \
    ca-certificates wget

RUN mkdir -p /src/strace /src/target && \
    wget -qO- https://github.com/strace/strace/releases/download/v${STRACE_VERSION}/strace-${STRACE_VERSION}.tar.xz | tar -xJf - -C /src/strace --strip-components=1

WORKDIR /src/strace

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --sbindir=/sbin \
    --libdir=/usr/lib64 \
    --disable-mpers \
    --without-libdw

RUN make -j$(nproc)
RUN make DESTDIR=/src/target install
RUN rm -rf /src/target/usr/share/man /src/target/usr/share/info

FROM scratch AS bundle
LABEL org.opencontainers.image.title="strace"
LABEL org.opencontainers.image.version="7.2"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="strace binary and tools"
COPY --from=build /src/target/ /
