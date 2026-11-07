FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=8.23.0
ARG LIBSSH2_VERSION=1.11.1
ARG NGHTTP2_VERSION=1.71.0

RUN git clone -q --single-branch --branch "curl-$(printf '%s' "$VERSION" | tr . _)" --depth 1 \
    https://github.com/curl/curl.git /src/curl

RUN git clone -q --single-branch --branch "libssh2-${LIBSSH2_VERSION}" --depth 1 \
    https://github.com/libssh2/libssh2.git /src/libssh2

RUN git clone -q --single-branch --branch "v${NGHTTP2_VERSION}" --depth 1 \
    https://github.com/nghttp2/nghttp2.git /src/nghttp2

FROM scratch
COPY --from=build /src/ /src/
