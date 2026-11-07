FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2026-11-05

RUN mkdir -p /src/ca-certificates && \
    curl -fsSL \
        "https://curl.se/ca/cacert-${VERSION}.pem" \
        -o /src/ca-certificates/cacert.pem

FROM scratch
COPY --from=build /src/ /src/
