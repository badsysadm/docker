FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.44

RUN git clone --single-branch --branch glibc-${VERSION} --depth 1 git://sourceware.org/git/glibc.git /src/glibc

FROM scratch
COPY --from=build /src/glibc/ /src
