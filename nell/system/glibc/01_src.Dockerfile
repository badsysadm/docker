FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.44

RUN git clone -q --single-branch --branch glibc-${VERSION} --depth 1 https://sourceware.org/git/glibc.git /src/glibc

FROM scratch
COPY --from=build /src/glibc/ /src
