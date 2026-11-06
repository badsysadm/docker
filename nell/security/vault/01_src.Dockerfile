FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.2.1

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 https://github.com/hashicorp/vault.git /src/vault

FROM scratch
COPY --from=build /src/ /src/
