FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG NCURSES_VERSION=6.6

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential ca-certificates wget pkg-config

RUN mkdir -p /src /src/target /src/build-libs

RUN wget --no-check-certificate https://invisible-island.net/archives/ncurses/ncurses-${NCURSES_VERSION}.tar.gz -O /src/ncurses.tar.gz && \
    tar -xf /src/ncurses.tar.gz -C /src

WORKDIR /src/ncurses-${NCURSES_VERSION}

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --bindir=/bin \
    --libdir=/lib/x86_64-linux-gnu \
    --without-manpages \
    --without-tests \
    --enable-static \
    --without-shared \
    --without-debug \
    --enable-widec \
    --enable-pc-files \
    --with-pkg-config-libdir=/usr/lib/x86_64-linux-gnu/pkgconfig \
    --enable-ext-colors \
    --enable-ext-mouse \
    CC="gcc -static" \
    LDFLAGS="-static" && \
    make -j$(nproc) && \
    make install DESTDIR=/src/target

RUN mkdir -p /src/target/lib/x86_64-linux-gnu && \
    cp -a /src/target/usr/lib/x86_64-linux-gnu/* /src/target/lib/x86_64-linux-gnu/ 2>/dev/null || true

FROM scratch AS bundle
LABEL org.opencontainers.image.title="ncurses"
LABEL org.opencontainers.image.version="6.6"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="ncurses libraries and terminal utilities"
COPY --from=build /src/target/ /
