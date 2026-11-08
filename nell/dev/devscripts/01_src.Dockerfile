FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.26.13

RUN mkdir -p /src/devscripts && \
    wget -qO- "https://deb.debian.org/debian/pool/main/d/devscripts/devscripts_${VERSION}.tar.xz" | \
    tar -xJf - -C /src/devscripts --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
