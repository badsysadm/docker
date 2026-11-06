FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.249

RUN mkdir -p /src/console-setup && \
    wget -qO /tmp/console-setup.tar.xz \
      "https://deb.debian.org/debian/pool/main/c/console-setup/console-setup_${VERSION}.tar.xz" && \
    tar -xJf /tmp/console-setup.tar.xz -C /src/console-setup --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
