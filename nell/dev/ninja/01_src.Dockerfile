FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.13.2

RUN mkdir -p /src/ninja && \
    wget -qO- "https://github.com/ninja-build/ninja/archive/refs/tags/v${VERSION}.tar.gz" | \
    tar -xzf - -C /src/ninja --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
