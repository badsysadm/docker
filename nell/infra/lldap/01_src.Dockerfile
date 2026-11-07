FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=0.6.3

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/lldap/lldap.git /src/lldap

FROM scratch
COPY --from=build /src/ /src/
