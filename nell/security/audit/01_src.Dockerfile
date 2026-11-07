FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=4.2.1

RUN git clone --depth 1 --branch "v${VERSION}" \
    https://github.com/linux-audit/audit-userspace.git /src/audit

FROM scratch
COPY --from=build /src/ /src/
