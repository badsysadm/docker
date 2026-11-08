ARG VERSION=3.8.2

FROM oci.badsysadm.local:80/dep/dev/bison:${VERSION} AS build
ARG VERSION

WORKDIR /src/bison

RUN find . -type f \( -name "configure" -o -name "Makefile.in" -o -name "aclocal.m4" \) -exec touch {} +

RUN ./configure \
    --prefix=/usr \
    --disable-nls \
    LDFLAGS="-static-libgcc"

RUN make -j$(nproc) MAKEINFO=true
RUN make install DESTDIR=/src/target MAKEINFO=true

RUN gcc -fPIC -shared -Ilib \
    -o /src/target/usr/lib/liby.so \
    lib/main.c lib/yyerror.c

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc \
    /src/target/usr/share/locale

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="bison"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU Bison parser generator"
COPY --from=build /src/target/ /target/
