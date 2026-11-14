FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.10.0

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/lz4/lz4.git /src/lz4

FROM scratch
COPY --from=build /src/ /src/
