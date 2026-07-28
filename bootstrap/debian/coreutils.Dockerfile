FROM mirror.gcr.io/library/debian:trixie AS build
ARG COREUTILS_VERSION=9.5
ARG FORCE_UNSAFE_CONFIGURE=1

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential pkg-config gettext \
    ca-certificates autoconf automake libtool autopoint wget bison texinfo

RUN mkdir -p /src/coreutils /src/target && \
    wget -qO- https://ftp.gnu.org/gnu/coreutils/coreutils-${COREUTILS_VERSION}.tar.xz | tar -xJf - -C /src/coreutils --strip-components=1

WORKDIR /src/coreutils

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-nls \
    --enable-single-binary=symlinks

RUN make -j$(nproc) V=1
RUN make install DESTDIR=/src/target

FROM scratch AS bundle
LABEL org.opencontainers.image.title="coreutils"
LABEL org.opencontainers.image.version="9.5"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU coreutils single binary"
COPY --from=build /src/target/ /
