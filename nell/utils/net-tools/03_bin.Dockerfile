ARG VERSION=2.10

FROM oci.badsysadm.local:80/dep/utils/net-tools:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION

WORKDIR /src/net-tools

RUN yes "" | make config
RUN make -j$(nproc)

RUN make installbin DESTDIR=/src/target

FROM scratch AS bundle
LABEL org.opencontainers.image.title="net-tools"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Linux networking utilities"

COPY --from=build /src/target/ /target/
