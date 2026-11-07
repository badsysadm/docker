FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.164.2

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/element-hq/synapse.git /src/synapse

FROM scratch
COPY --from=build /src/ /src/
