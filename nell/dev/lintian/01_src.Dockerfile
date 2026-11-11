FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.142.0

RUN git clone -q --single-branch --branch "${VERSION}" --depth 1 \
    https://salsa.debian.org/lintian/lintian.git /src/lintian

# A newer Debian::DistroInfo is required by Lintian 2.142.0 than Trixie provides.
RUN git clone -q --single-branch --branch "debian/1.20" --depth 1 \
    https://salsa.debian.org/debian/distro-info.git /src/distro-info

FROM scratch
COPY --from=build /src/ /src/
