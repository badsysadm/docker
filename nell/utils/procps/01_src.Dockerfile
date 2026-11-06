FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=4.0.7

RUN mkdir -p /src/procps && \
    wget -qO- https://downloads.sourceforge.net/project/procps-ng/Production/procps-ng-${VERSION}.tar.xz | \
        tar -xJf - -C /src/procps --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
