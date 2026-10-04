FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=7.2

RUN mkdir -p /src/strace /src/target && \
    wget -qO- https://github.com/strace/strace/releases/download/v${VERSION}/strace-${VERSION}.tar.xz | tar -xJf - -C /src/strace --strip-components=1

FROM scratch
COPY --from=build /src/strace/ /src
