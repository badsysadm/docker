FROM mirror.gcr.io/library/debian:trixie AS build
ARG TAR_VERSION=1.35
ARG FORCE_UNSAFE_CONFIGURE=1

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential pkg-config gettext \
    ca-certificates autoconf automake libtool autopoint wget \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libzstd-dev \
    libacl1-dev 

RUN mkdir -p /src/tar /src/target && \
    wget -qO- https://ftp.gnu.org/gnu/tar/tar-${TAR_VERSION}.tar.gz | tar -xzf - -C /src/tar --strip-components=1

WORKDIR /src/tar

COPY tar.patches /src/
RUN patch -p0 < /src/tar.patches

RUN autoreconf -f -i
RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-nls \
    --without-selinux \
    --with-gzip=gzip \
    --with-bzip2=bzip2 \
    --with-xz=xz \
    --with-lzma=lzma \
    --with-lzop=lzop \
    --with-zstd=zstd

RUN make -j$(nproc) V=1
RUN make install DESTDIR=/src/target

FROM scratch AS bundle
LABEL org.opencontainers.image.title="tar"
LABEL org.opencontainers.image.version="1.35"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU Tape Archiver"
COPY --from=build /src/target/ /
