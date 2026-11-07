ARG VERSION=1.8.2

FROM oci.badsysadm.local:80/dep/utils/jq:${VERSION} AS build
ARG VERSION

WORKDIR /src/jq

RUN ./configure \
    --prefix=/usr \
    --disable-docs \
    --disable-shared \
    --enable-static \
    --with-oniguruma=builtin \
    LDFLAGS="-static-libgcc"

RUN make -j1
RUN install -D -m 0755 jq /src/target/usr/bin/jq

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="jq"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Command-line JSON processor"
COPY --from=build /src/target/ /target/
