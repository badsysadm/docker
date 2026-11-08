ARG VERSION=1.4.21

FROM oci.badsysadm.local:80/dep/dev/m4:${VERSION} AS build
ARG VERSION

WORKDIR /src/m4

RUN find . -type f \( -name "configure" -o -name "Makefile.in" -o -name "aclocal.m4" \) -exec touch {} +

RUN ./configure \
    --prefix=/usr \
    --disable-nls \
    LDFLAGS="-static-libgcc"

RUN make -C lib -j$(nproc) && \
    make -C src -j$(nproc)
RUN make -C src install DESTDIR=/src/target

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc \
    /src/target/usr/share/locale

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="m4"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU m4 macro processor"
COPY --from=build /src/target/ /target/
