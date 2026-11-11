FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.142.0

RUN git clone -q --single-branch --branch "${VERSION}" --depth 1 \
    https://salsa.debian.org/lintian/lintian.git /src/lintian

# A newer Debian::DistroInfo is required by Lintian 2.142.0 than Trixie provides.
# Pin the upstream commit that adds Debian::DistroInfo::get_all_series.
# It is reachable from the default branch; no unverified release tag is used.
RUN git clone -q --single-branch \
    https://salsa.debian.org/debian/distro-info.git /src/distro-info && \
    git -C /src/distro-info checkout -q 1a19873b2bcb52b24bd096ce098f2f82f6e7630e

FROM scratch
COPY --from=build /src/ /src/
