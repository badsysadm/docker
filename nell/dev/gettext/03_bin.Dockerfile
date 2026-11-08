ARG VERSION=1.0

FROM oci.badsysadm.local:80/dep/dev/gettext:${VERSION} AS build
ARG VERSION

WORKDIR /src/gettext

RUN find . -type f \( -name "configure" -o -name "Makefile.in" -o -name "aclocal.m4" \) -exec touch {} +

RUN ./configure \
    --prefix=/usr \
    --disable-nls \
    --disable-java \
    --disable-csharp \
    --disable-openmp \
    --disable-libtextstyle \
    --without-emacs \
    --with-included-libunistring \
    --enable-static \
    --enable-shared \
    LDFLAGS="-static-libgcc"

RUN make -j$(nproc) MAKEINFO=true
RUN make install DESTDIR=/src/target MAKEINFO=true

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc \
    /src/target/usr/share/locale && \
    find /src/target -type f -name '*.la' -delete

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="gettext"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU Gettext internationalization tools"
COPY --from=build /src/target/ /target/
