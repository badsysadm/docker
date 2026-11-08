FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.3-20260721

RUN wget --tries=3 -O /tmp/dialog.tgz https://invisible-island.net/archives/dialog/dialog-${VERSION}.tgz && \
    tar -xzf /tmp/dialog.tgz -C /src && \
    mv /src/dialog-${VERSION} /src/dialog && \
    rm /tmp/dialog.tgz

FROM scratch
COPY --from=build /src/ /src