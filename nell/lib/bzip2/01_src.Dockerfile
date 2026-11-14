FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.0.8

RUN git clone -q --single-branch --branch "bzip2-${VERSION}" --depth 1 \
    https://github.com/libarchive/bzip2.git /src/bzip2

FROM scratch
COPY --from=build /src/ /src/
