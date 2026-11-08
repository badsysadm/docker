FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.13.2

RUN git clone --depth 1 --branch "v${VERSION}" \
    https://github.com/ninja-build/ninja.git /src/ninja

FROM scratch
COPY --from=build /src/ /src/
