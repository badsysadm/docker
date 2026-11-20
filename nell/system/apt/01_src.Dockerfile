FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.3.8

RUN git clone -q --single-branch --branch ${VERSION} --depth 1 https://salsa.debian.org/apt-team/apt.git /src/apt

FROM scratch
COPY --from=build /src/ /src
