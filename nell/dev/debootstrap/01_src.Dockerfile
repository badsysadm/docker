FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.0.145

RUN git clone -q --single-branch --branch "${VERSION}" --depth 1 \
    https://salsa.debian.org/installer-team/debootstrap.git /src/debootstrap

FROM scratch
COPY --from=build /src/debootstrap/ /src/debootstrap/
