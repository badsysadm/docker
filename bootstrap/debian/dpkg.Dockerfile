FROM mirror.gcr.io/library/debian:trixie
ARG DPKG_VERSION=1.22.11

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential pkg-config gettext \
    liblzma-dev libzstd-dev libbz2-dev liblz4-dev zlib1g-dev \
    libmd-dev \
    git ca-certificates autoconf automake libtool autopoint flex bison

RUN git clone --single-branch --branch ${DPKG_VERSION} --depth 1 https://git.dpkg.org/git/dpkg/dpkg.git /src/dpkg
WORKDIR /src/dpkg

# Вырезаем директорию man из сборки
RUN sed -i 's/\bman\b//g' Makefile.am

RUN ./autogen

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-shared \
    --enable-static \
    --disable-dselect \
    --disable-start-stop-daemon \
    --disable-update-alternatives \
    --disable-devel-docs \
    --disable-doc \
    --disable-pod-doc \
    --disable-nls \
    --disable-libselinux \
    CFLAGS="-O2" \
    LDFLAGS="-Wl,-Bstatic -llzma -lzstd -lbz2 -llz4 -lz -lmd -Wl,-Bdynamic"

RUN make -j$(nproc)
RUN make install DESTDIR=/usr/local
