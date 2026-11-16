FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=8.23.0

RUN git clone -q --single-branch --branch "curl-$(printf '%s' "$VERSION" | tr . _)" --depth 1 \
    https://github.com/curl/curl.git /src/curl

FROM scratch
COPY --from=build /src/ /src/
