FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=127

RUN mkdir -p /src/polkit && \
    wget -qO- https://github.com/polkit-org/polkit/archive/refs/tags/${VERSION}.tar.gz | \
        tar -xzf - -C /src/polkit --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
