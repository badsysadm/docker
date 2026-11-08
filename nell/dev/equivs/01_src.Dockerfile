FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.3.3

RUN mkdir -p /src/equivs && \
    wget -qO- "https://deb.debian.org/debian/pool/main/e/equivs/equivs_${VERSION}.tar.xz" | \
    tar -xJf - -C /src/equivs --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
