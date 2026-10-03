FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=0.19.4

RUN mkdir -p /src/aide && \
    wget -qO- https://github.com/aide/aide/releases/download/v${VERSION}/aide-${VERSION}.tar.gz | tar -xzf - -C /src/aide --strip-components=1

FROM scratch
COPY --from=build /src/ /src
