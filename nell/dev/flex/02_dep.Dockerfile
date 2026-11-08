ARG VERSION=2.6.4
ARG M4_VERSION=1.4.21

FROM oci.badsysadm.local:80/src/dev/flex:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/dev/m4:${M4_VERSION} AS m4_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=m4_image /target/usr/bin/m4 /usr/bin/m4
COPY --from=src_image /src/ /src/
