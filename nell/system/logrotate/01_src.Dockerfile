FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.22.0

RUN mkdir -p /src/logrotate /src/target && \
    wget -qO- \
        https://github.com/logrotate/logrotate/releases/download/${VERSION}/logrotate-${VERSION}.tar.xz \
        | tar -xJf - -C /src/logrotate --strip-components=1

FROM scratch
COPY --from=build /src/ /src
