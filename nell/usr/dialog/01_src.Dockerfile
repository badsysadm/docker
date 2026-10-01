FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.3-20260721

RUN wget --no-check-certificate -qO- https://invisible-island.net/archives/dialog/dialog-${DIALOG_VERSION}.tgz | tar -xz -C /src

FROM scratch
COPY --from=build /src/glibc/ /src
