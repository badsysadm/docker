FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=20250605

RUN mkdir -p /src/iputils /src/target && \
    wget -qO- https://github.com/iputils/iputils/archive/refs/tags/${VERSION}.tar.gz | tar -xzf - -C /src/iputils --strip-components=1

FROM scratch
COPY --from=build /src/iputils/ /src
