ARG VERSION=2.8.1

FROM oci.badsysadm.local:80/dep/dev/patch:${VERSION} AS build
ARG VERSION

WORKDIR /src/patch

RUN find . -type f \( -name "configure" -o -name "Makefile.in" -o -name "aclocal.m4" \) -exec touch {} +

RUN ./configure \
    --prefix=/usr \
    CPPFLAGS="-I/usr/local/include" \
    LDFLAGS="-static-libgcc -L/usr/local/lib -Wl,-Bstatic" \
    LIBS="-Wl,-Bdynamic"

RUN make -C lib -j$(nproc) && \
    make -C src -j$(nproc)
RUN install -Dm755 src/patch /src/target/usr/bin/patch

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="patch"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU Patch diff application utility"
COPY --from=build /src/target/ /target/
