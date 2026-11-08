FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.5.3

RUN mkdir -p /src/htop && \
    wget -qO- "https://github.com/htop-dev/htop/releases/download/${VERSION}/htop-${VERSION}.tar.xz" | \
    tar -xJf - -C /src/htop --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
