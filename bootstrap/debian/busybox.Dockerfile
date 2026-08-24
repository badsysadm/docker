FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG BUSYBOX_VERSION=1_37_0

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential libncurses5-dev libpam0g-dev libsepol-dev libselinux1-dev \
    git ca-certificates perl

RUN git clone --single-branch --branch ${BUSYBOX_VERSION} --depth 1 https://github.com/vda-linux/busybox_mirror.git /src/busybox
RUN mkdir -p /src/target
WORKDIR /src/busybox
COPY busybox.buildconfig /src/busybox/.config
RUN make clean
RUN make
RUN make install DESTDIR=/src/target
WORKDIR /src/target
RUN rm -rf usr/bin/*
RUN mv -v bin/* usr/bin/
WORKDIR /src/target/usr/bin
RUN ln -s busybox diff
RUN ln -s busybox find
RUN ln -s busybox test

FROM scratch AS bundle
LABEL org.opencontainers.image.title="busybox"
LABEL org.opencontainers.image.version="1.37.0"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Tiny versions of many common UNIX utilities"
COPY --from=build /src/target/ /
