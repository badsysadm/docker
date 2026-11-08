ARG VERSION=1.0

FROM oci.badsysadm.local:80/dep/dev/autopoint:${VERSION} AS build
ARG VERSION

RUN install -Dm755 /usr/bin/autopoint /src/target/usr/bin/autopoint && \
    mkdir -p /src/target/usr/share/gettext && \
    cp -a /usr/share/gettext/. /src/target/usr/share/gettext/

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="autopoint"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="GNU Gettext Autotools infrastructure bootstrap"
COPY --from=build /src/target/ /target/
