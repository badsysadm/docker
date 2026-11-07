ARG VERSION=2026-11-05

FROM oci.badsysadm.local:80/dep/security/ca-certificates:${VERSION} AS build
ARG VERSION

RUN install -D -m 0644 \
    /src/ca-certificates/cacert.pem \
    /src/target/etc/ssl/certs/ca-certificates.crt

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="ca-certificates"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Mozilla CA bundle for OpenSSL"
COPY --from=build /src/target/ /target/
