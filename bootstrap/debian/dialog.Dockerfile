FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG DIALOG_VERSION=1.3-20260721

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential ca-certificates wget libncursesw5-dev libtinfo-dev pkg-config

RUN mkdir -p /src /src/target

RUN wget --no-check-certificate https://invisible-island.net/archives/dialog/dialog-${DIALOG_VERSION}.tgz -O /src/dialog.tgz && \
    tar -xf /src/dialog.tgz -C /src

WORKDIR /src/dialog-${DIALOG_VERSION}

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --bindir=/bin \
    --mandir=/usr/share/man \
    --with-ncursesw \
    --enable-widec \
    LDFLAGS="-static-libgcc -Wl,-Bstatic $(pkg-config --libs ncursesw tinfo) -Wl,-Bdynamic" && \
    make -j$(nproc) && \
    make install DESTDIR=/src/target

FROM scratch AS bundle
LABEL org.opencontainers.image.title="dialog"
LABEL org.opencontainers.image.version="1.3-20260721"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="dialog binary and tools"
COPY --from=build /src/target/ /
