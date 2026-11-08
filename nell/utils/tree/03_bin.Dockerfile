ARG VERSION=2.3.2

FROM oci.badsysadm.local:80/dep/utils/tree:${VERSION} AS build
ARG VERSION

WORKDIR /src/tree

RUN make -j$(nproc) \
    CFLAGS="-O2 -std=c11 -Wall -Wextra" \
    LDFLAGS="-static-libgcc"

RUN install -Dm755 tree /src/target/usr/bin/tree

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="tree"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Directory tree listing utility"
COPY --from=build /src/target/ /target/
