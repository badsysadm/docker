FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.0.2

RUN git clone -q --single-branch --branch "libassuan-${VERSION}" --depth 1 \
    https://github.com/gpg/libassuan.git /src/libassuan

FROM scratch
COPY --from=build /src/ /src/
