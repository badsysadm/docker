FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.7.3

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 https://github.com/etcd-io/etcd.git /src/etcd

FROM scratch
COPY --from=build /src/ /src/
