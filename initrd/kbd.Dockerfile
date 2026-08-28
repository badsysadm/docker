FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG KBD_VERSION=2.10.0

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential ca-certificates wget xz-utils pkg-config check bison flex

WORKDIR /src
RUN wget https://mirrors.edge.kernel.org/pub/linux/utils/kbd/kbd-${KBD_VERSION}.tar.xz -O - | tar -xJ

WORKDIR /src/kbd-${KBD_VERSION}

RUN ./configure --prefix=/usr \
    --disable-vlock \
    --disable-nls \
    --disable-tests \
    --disable-compress

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target
RUN rm -rf /src/target/usr/share/man

FROM scratch AS bundle
LABEL org.opencontainers.image.title="kbd"
LABEL org.opencontainers.image.version="2.10.0"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Linux keyboard and console utilities"
COPY --from=build /src/target/ /
