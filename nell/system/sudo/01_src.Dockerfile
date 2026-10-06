FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.9.17p2

RUN mkdir -p /src/sudo /src/target && \
    wget -qO- https://github.com/sudo-project/sudo/archive/refs/tags/v${VERSION}.tar.gz \
    | tar -xzf - -C /src/sudo --strip-components=1

FROM scratch
COPY --from=build /src/ /src
