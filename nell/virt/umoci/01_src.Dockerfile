FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=0.6.0

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 https://github.com/opencontainers/umoci.git /src/umoci

FROM scratch
COPY --from=build /src/ /src/
