FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.1.23

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 https://github.com/project-zot/zot.git /src/zot

FROM scratch
COPY --from=build /src/ /src/
