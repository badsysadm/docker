ARG VERSION=2.42.2

FROM oci.badsysadm.local:80/src/utils/util-linux:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=src_image /src /src/util-linux/
