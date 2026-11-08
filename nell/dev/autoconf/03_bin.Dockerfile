ARG VERSION=2.73

FROM oci.badsysadm.local:80/dep/dev/autoconf:${VERSION} AS build
ARG VERSION

WORKDIR /src/autoconf

RUN find . -type f \( -name "configure" -o -name "Makefile.in" -o -name "aclocal.m4" \) -exec touch {} +

RUN ./configure --prefix=/usr

RUN make -j$(nproc) MAKEINFO=true HELP2MAN=true
RUN make install DESTDIR=/src/target MAKEINFO=true HELP2MAN=true

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="autoconf"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU Autoconf configuration script generator"
COPY --from=build /src/target/ /target/
