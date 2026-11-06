FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=4.11

RUN mkdir -p /src/quota && \
    wget -qO- "https://downloads.sourceforge.net/project/linuxquota/quota-tools/${VERSION}/quota-${VERSION}.tar.gz" | \
    tar -xzf - -C /src/quota --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
