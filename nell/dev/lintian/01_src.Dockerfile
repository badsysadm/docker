FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.142.0

RUN git clone -q --single-branch --branch "${VERSION}" --depth 1 \
    https://salsa.debian.org/lintian/lintian.git /src/lintian

FROM scratch
COPY --from=build /src/ /src/
