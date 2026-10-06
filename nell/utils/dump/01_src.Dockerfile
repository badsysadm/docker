FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=0.4b56

RUN mkdir -p /src/dump /src/target && \
    wget -qO- https://downloads.sourceforge.net/project/dump/dump/${VERSION}/dump-${VERSION}.tar.gz \
    | tar -xzf - -C /src/dump --strip-components=1

FROM scratch
COPY --from=build /src/ /src
