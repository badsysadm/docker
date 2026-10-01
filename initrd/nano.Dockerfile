FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG NANO_VERSION=9.2

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential ca-certificates wget xz-utils pkg-config libncurses-dev

WORKDIR /src
RUN wget https://ftp.gnu.org/gnu/nano/nano-${NANO_VERSION}.tar.xz -O - | tar -xJ

WORKDIR /src/nano-${NANO_VERSION}

RUN ./configure --prefix=/usr \
    --enable-static \
    --disable-nls \
    --disable-shared

RUN make -j$(nproc) LDFLAGS="-static"
RUN make install DESTDIR=/src/target
RUN rm -rf /src/target/usr/share/man

FROM scratch AS bundle
LABEL org.opencontainers.image.title="nano"
LABEL org.opencontainers.image.version="9.2"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU nano text editor"
COPY --from=build /src/target/ /
