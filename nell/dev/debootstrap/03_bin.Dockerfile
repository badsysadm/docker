ARG VERSION=1.0.145

FROM oci.badsysadm.local:80/dep/dev/debootstrap:${VERSION} AS build
ARG VERSION

WORKDIR /src/debootstrap
COPY patches/nell-inrelease-trailing-whitespace.patch /src/patches/nell-inrelease-trailing-whitespace.patch
COPY patches/nell-newest-debian-version.patch /src/patches/nell-newest-debian-version.patch
RUN patch -p1 < /src/patches/nell-inrelease-trailing-whitespace.patch
RUN patch -p1 < /src/patches/nell-newest-debian-version.patch
RUN make install DESTDIR=/src/target

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="debootstrap"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="debootstrap shell scripts and runtime helpers"
COPY --from=build /src/target/ /target/
