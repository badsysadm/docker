FROM mirror.gcr.io/library/debian:trixie AS build
ARG GLIBC_VERSION=glibc-2.44

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential git gawk pkg-config bison python3 linux-libc-dev

RUN mkdir -p /src/target
RUN git clone --single-branch --branch ${GLIBC_VERSION} --depth 1 git://sourceware.org/git/glibc.git /src/glibc
WORKDIR /src/glibc/build

RUN ../configure --prefix=/usr
RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

FROM scratch AS bundle
LABEL org.opencontainers.image.title="glibc"
LABEL org.opencontainers.image.version="2.44"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="The main standard C library"
COPY --from=build /src/target/ /
