ARG VERSION=2.44

FROM oci.badsysadm.local:80/src/system/glibc:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=src_image /src /src/glibc/
