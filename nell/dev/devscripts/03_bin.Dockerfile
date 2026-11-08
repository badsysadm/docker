ARG VERSION=2.26.13

FROM oci.badsysadm.local:80/dep/dev/devscripts:${VERSION} AS build
ARG VERSION

WORKDIR /src/devscripts

RUN mkdir -p /src/target/usr/bin && \
    pp -B -M Dpkg::Changelog::Parse \
       -o /src/target/usr/bin/mk-build-deps \
       scripts/mk-build-deps.pl && \
    chmod 755 /src/target/usr/bin/mk-build-deps

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="devscripts"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="mk-build-deps packaged with PAR::Packer"
COPY --from=build /src/target/ /target/
