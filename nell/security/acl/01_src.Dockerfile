FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.4.0

RUN mkdir -p /src/acl && \
    wget -qO- https://download.savannah.nongnu.org/releases/acl/acl-${VERSION}.tar.xz | \
        tar -xJf - -C /src/acl --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
