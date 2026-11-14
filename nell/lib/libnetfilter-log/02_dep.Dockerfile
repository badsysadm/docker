ARG VERSION=1.0.2
ARG LIBNFNETLINK_VERSION=1.0.2

FROM oci.badsysadm.local:80/src/lib/libnetfilter-log:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/lib/libnfnetlink:${LIBNFNETLINK_VERSION} AS libnfnetlink_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=libnfnetlink_image /target/usr/local/include/ /usr/local/include/
COPY --from=libnfnetlink_image /target/usr/local/lib/ /usr/local/lib/

COPY --from=src_image /src/ /src/
