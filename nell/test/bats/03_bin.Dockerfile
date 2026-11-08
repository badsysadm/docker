ARG VERSION=1.14.0

FROM oci.badsysadm.local:80/dep/test/bats:${VERSION} AS build
ARG VERSION

WORKDIR /src/bats-core

RUN ./install.sh /src/target/usr

# Keep each library's upstream runtime layout under BATS_LIB_PATH=/usr/lib/bats.
RUN install -D -m 0644 -t /src/target/usr/lib/bats/bats-support \
    /src/bats-support/load.bash
RUN install -D -m 0644 -t /src/target/usr/lib/bats/bats-support/src \
    /src/bats-support/src/*.bash

RUN install -D -m 0644 -t /src/target/usr/lib/bats/bats-assert \
    /src/bats-assert/load.bash
RUN install -D -m 0644 -t /src/target/usr/lib/bats/bats-assert/src \
    /src/bats-assert/src/*.bash

RUN install -D -m 0644 -t /src/target/usr/lib/bats/bats-file \
    /src/bats-file/load.bash
RUN install -D -m 0644 -t /src/target/usr/lib/bats/bats-file/src \
    /src/bats-file/src/*.bash

RUN install -D -m 0644 -t /src/target/usr/lib/bats/bats-detik/lib \
    /src/bats-detik/lib/*.bash

RUN rm -rf \
    /src/target/usr/share/man \
    /src/target/usr/share/info \
    /src/target/usr/share/doc \
    /src/target/usr/share/locale

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="bats"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Bats-core with support, assert, detik and file libraries"
COPY --from=build /src/target/ /target/
