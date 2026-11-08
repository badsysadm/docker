FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.6.4

RUN git clone --depth 1 --branch "v${VERSION}" \
    https://github.com/westes/flex.git /src/flex

FROM scratch
COPY --from=build /src/ /src/
