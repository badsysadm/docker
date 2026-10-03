ARG VERSION=1.1.7
ARG LIBNFTNL_VERSION=1.3.2

FROM oci.badsysadm.local:80/src/net/nftables:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/net/libnftnl:${LIBNFTNL_VERSION} AS libnftnl_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=libnftnl_image /target/usr/ /usr/
COPY --from=src_image /src/ /src/
