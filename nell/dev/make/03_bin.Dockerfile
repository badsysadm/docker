ARG VERSION=4.4.1

FROM oci.badsysadm.local:80/dep/dev/make:${VERSION} AS build
ARG VERSION

WORKDIR /src/make

RUN find . -type f \( -name "configure" -o -name "Makefile.in" -o -name "aclocal.m4" \) -exec touch {} +

RUN ./configure \
    --prefix=/usr \
    --disable-nls \
    --without-guile \
    LDFLAGS="-static-libgcc"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc \
    /src/target/usr/share/locale

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="make"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU Make build automation utility"
COPY --from=build /src/target/ /target/
