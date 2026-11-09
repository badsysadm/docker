ARG VERSION=0.1.0

FROM oci.badsysadm.local:80/dep/dev/dpkg-cvecheck:${VERSION} AS build
ARG VERSION

WORKDIR /src/dpkg-cvecheck
RUN make install DESTDIR=/src/target

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="dpkg-cvecheck"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Debian source package CVE verifier and vulnerability index"
COPY --from=build /src/target/ /target/
