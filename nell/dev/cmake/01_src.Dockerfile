FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=4.4.5

RUN mkdir -p /src/cmake && \
    wget -qO- "https://cmake.org/files/v4.4/cmake-${VERSION}.tar.gz" | \
    tar -xzf - -C /src/cmake --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
