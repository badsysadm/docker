FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=4.4.5

RUN mkdir -p /src/cmake && \
    wget --tries=3 -nv -O- "https://cmake.org/files/v${VERSION%.*}/cmake-${VERSION}.tar.gz" 2>/tmp/cmake-wget.err | \
    tar -xzf - -C /src/cmake --strip-components=1 || { cat /tmp/cmake-wget.err >&2; exit 1; }

FROM scratch
COPY --from=build /src/ /src/
