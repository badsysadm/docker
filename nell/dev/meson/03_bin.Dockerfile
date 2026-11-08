ARG VERSION=1.12.1

FROM oci.badsysadm.local:80/dep/dev/meson:${VERSION} AS build
ARG VERSION

WORKDIR /src/meson

RUN find meson.py mesonbuild -exec touch -d '@315532800' {} + && \
    mkdir -p /src/target/usr/bin && \
    python3 packaging/create_zipapp.py \
        --outfile /src/target/usr/bin/meson \
        --interpreter '/usr/bin/env python3' \
        . && \
    chmod 755 /src/target/usr/bin/meson

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="meson"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Meson build system"
COPY --from=build /src/target/ /target/
