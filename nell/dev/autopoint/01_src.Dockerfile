ARG VERSION=1.0

FROM oci.badsysadm.local:80/src/dev/gettext:${VERSION} AS src_image

FROM scratch
COPY --from=src_image /src/ /src/
