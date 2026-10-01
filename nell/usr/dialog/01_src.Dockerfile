FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.3-20260721

RUN wget --no-check-certificate -qO- https://invisible-island.net/archives/dialog/dialog-${VERSION}.tgz | tar -xz -C /src
RUN mv /src/dialog-${VERSION} /src/dialog

FROM scratch
COPY --from=build /src/dialog/ /src
