ARG VERSION=1.13.2

FROM oci.badsysadm.local:80/dep/dev/ninja:${VERSION} AS build
ARG VERSION

WORKDIR /src/ninja

RUN python3 configure.py --bootstrap
RUN install -Dm755 ninja /src/target/usr/bin/ninja

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="ninja"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Ninja build system"
COPY --from=build /src/target/ /target/
