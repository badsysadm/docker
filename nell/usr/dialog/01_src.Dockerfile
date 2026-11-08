FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.3-20260721

RUN wget -nv -O- https://invisible-mirror.net/archives/dialog/dialog-${VERSION}.tgz 2>/tmp/dialog-wget.err | \
    tar -xz -C /src || { cat /tmp/dialog-wget.err >&2; exit 1; }
RUN mv /src/dialog-${VERSION} /src/dialog

FROM scratch
COPY --from=build /src/ /src