ARG VERSION=3.6.5

FROM oci.badsysadm.local:80/src/security/openssl:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

RUN apt-get -qq update && apt-get install -y -qq build-essential ca-certificates wget perl pkg-config zlib1g-dev libzstd-dev

COPY --from=src_image /src/ /src
