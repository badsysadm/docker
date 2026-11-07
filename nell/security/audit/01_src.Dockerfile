FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=4.2.1

RUN mkdir -p /src/audit && \
    wget -qO- \
        "https://github.com/linux-audit/audit-userspace/archive/refs/tags/v${VERSION}.tar.gz" | \
    tar -xzf - -C /src/audit --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
