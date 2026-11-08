FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.26.13
ARG CONFLICTS_VERSION=2.25.15+deb13u1

RUN mkdir -p /src/devscripts && \
    wget -qO- "https://deb.debian.org/debian/pool/main/d/devscripts/devscripts_${VERSION}.tar.xz" | \
    tar -xJf - -C /src/devscripts --strip-components=1

# deb-check-file-conflicts is not present in the 2.26.13 source tree.
RUN mkdir -p /src/devscripts/legacy && \
    wget -qO- "https://deb.debian.org/debian/pool/main/d/devscripts/devscripts_${CONFLICTS_VERSION}.tar.xz" | \
    tar -xJf - -C /src/devscripts/legacy --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
