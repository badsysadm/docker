ARG VERSION=2.6.2

FROM oci.badsysadm.local:80/dep/dev/libtool:${VERSION} AS build
ARG VERSION

WORKDIR /src/libtool

RUN find . -type f \( -name "configure" -o -name "Makefile.in" -o -name "aclocal.m4" \) -exec touch {} +

RUN ./configure \
    --prefix=/usr \
    --enable-ltdl-install \
    --enable-static \
    --enable-shared \
    LDFLAGS="-static-libgcc"

RUN make -j$(nproc) MAKEINFO=true HELP2MAN=true
RUN make install DESTDIR=/src/target MAKEINFO=true HELP2MAN=true

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc && \
    find /src/target -type f -name '*.la' -delete

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="libtool"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU Libtool and libltdl"
COPY --from=build /src/target/ /target/
