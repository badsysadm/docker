FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.24.1

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 https://github.com/podman-container-tools/skopeo.git /src/skopeo

FROM scratch
COPY --from=build /src/ /src/
