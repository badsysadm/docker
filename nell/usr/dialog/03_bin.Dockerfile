ARG VERSION=1.3-20260721

FROM oci.badsysadm.local:80/dep/usr/dialog:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/dialog-${DIALOG_VERSION}
RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --bindir=/bin \
    --mandir=/usr/share/man \
    --with-ncursesw \
    --enable-widec \
    LDFLAGS="-static-libgcc -Wl,-Bstatic $(pkg-config --libs ncursesw tinfo) -Wl,-Bdynamic"
RUN make -j$(nproc)
RUN make install DESTDIR=/src/target
    
FROM scratch AS bundle
LABEL org.opencontainers.image.title="dialog"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="dialog bundle"
COPY --from=build /src/target/ /target/
