FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.71.0

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/nghttp2/nghttp2.git /src/nghttp2

FROM scratch
COPY --from=build /src/ /src/
