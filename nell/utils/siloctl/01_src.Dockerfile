FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2026-10-26T00-00-00Z

RUN git clone -q --single-branch --branch "RELEASE.${VERSION}" --depth 1 \
    https://github.com/pgsty/mc.git /src/siloctl

FROM scratch
COPY --from=build /src/ /src/
