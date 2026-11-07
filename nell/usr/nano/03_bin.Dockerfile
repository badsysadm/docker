ARG VERSION=9.2

FROM oci.badsysadm.local:80/dep/usr/nano:${VERSION} AS build
ARG VERSION

WORKDIR /src/nano
RUN find . -type f \( -name "configure" -o -name "Makefile.in" -o -name "aclocal.m4" \) -exec touch {} +
RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --disable-nls \
    LDFLAGS="-static-libgcc" \
    LIBS="-Wl,-Bstatic -lncursesw -ltinfo -Wl,-Bdynamic"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="nano"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU nano text editor"
COPY --from=build /src/target/ /target/
