FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=0.19.4
ARG SHA256=47ab7c696f0745911479a41f90d7ad99d26536e186d66c4aad093bc72d20ff5f

RUN mkdir -p /src/aide /src/target && \
    wget -qO /tmp/aide.tar.gz https://github.com/aide/aide/releases/download/v${VERSION}/aide-${VERSION}.tar.gz && \
    echo "${SHA256}  /tmp/aide.tar.gz" | sha256sum -c - && \
    tar -xzf /tmp/aide.tar.gz -C /src/aide --strip-components=1

FROM scratch
COPY --from=build /src/aide/ /src
