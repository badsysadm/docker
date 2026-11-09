FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=0.1.0

COPY src/ /src/dpkg-cvecheck/

FROM scratch
COPY --from=build /src/ /src/
