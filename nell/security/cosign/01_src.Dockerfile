FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.1.4

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/sigstore/cosign.git /src/cosign

FROM scratch
COPY --from=build /src/ /src/
