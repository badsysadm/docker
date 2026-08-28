FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG BASH_VERSION=bash-5.3

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential git pkg-config ca-certificates

RUN mkdir -p /src /src/target

RUN git clone --single-branch --branch ${BASH_VERSION} --depth 1 https://git.savannah.gnu.org/git/bash.git /src/bash

WORKDIR /src/bash

RUN ./configure \
    --prefix=/usr \
    --bindir=/bin \
    --without-bash-malloc \
    --enable-static-link \
    --enable-mem-scramble \
    --enable-net-redirections \
    --enable-xpg-echo-default \
    --disable-help-builtin \
    --enable-year2038 \
    --disable-nls \
    --disable-rpath \
    CC="gcc -static" \
    LDFLAGS="-static" && \
    make -j$(nproc) && \
    make install DESTDIR=/src/target

FROM scratch AS bundle
LABEL org.opencontainers.image.title="bash"
LABEL org.opencontainers.image.version="5.3"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Bourne-Again SHell statically linked"
COPY --from=build /src/target/ /
