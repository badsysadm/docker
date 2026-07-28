FROM mirror.gcr.io/library/debian:trixie AS build
ARG DPKG_VERSION=1.22.11

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential pkg-config gettext \
    liblzma-dev libzstd-dev libbz2-dev liblz4-dev zlib1g-dev \
    libmd-dev \
    git ca-certificates autoconf automake libtool autopoint flex bison

RUN git clone --single-branch --branch ${DPKG_VERSION} --depth 1 https://git.dpkg.org/git/dpkg/dpkg.git /src/dpkg
RUN mkdir -p /src/target
WORKDIR /src/dpkg

COPY dpkg.patches /src/
RUN git apply /src/dpkg.patches

# Вырезаем директорию man из сборки
 #RUN sed -i 's/\bman\b//g' Makefile.am

RUN autoreconf -f -i

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-shared \
    --enable-static \
    --disable-dselect \
    --disable-start-stop-daemon \
    --enable-update-alternatives \
    --disable-devel-docs \
    --disable-nls

RUN make -j$(nproc) V=1
RUN make install DESTDIR=/src/target

FROM scratch AS bundle
LABEL org.opencontainers.image.title="dpkg"
LABEL org.opencontainers.image.version="1.22.11"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Low-level package manager"
COPY --from=build /src/target/ /
