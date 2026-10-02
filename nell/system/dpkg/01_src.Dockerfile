FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.22.11

RUN git clone -q --single-branch --branch ${VERSION} --depth 1 https://git.dpkg.org/git/dpkg/dpkg.git /src/dpkg

FROM scratch
COPY --from=build /src/ /src
