ARG VERSION=1.19

FROM oci.badsysadm.local:80/dep/dev/automake:${VERSION} AS build
ARG VERSION

WORKDIR /src/automake

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
LABEL org.opencontainers.image.title="automake"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU Automake Makefile.in generator"
COPY --from=build /src/target/ /target/
