ARG VERSION=1.7
ARG OPENSSL_VERSION=3.6.5
ARG ZLIB_VERSION=1.3.1
ARG ZSTD_VERSION=1.5.7

FROM oci.badsysadm.local:80/src/kernel/fsverity-utils:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/security/openssl:${OPENSSL_VERSION} AS openssl_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM oci.badsysadm.local:80/bin/utils/zstd:${ZSTD_VERSION} AS zstd_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

# Use the existing nell library artifacts for static third-party linking.
COPY --from=openssl_image /target/usr/ /usr/
COPY --from=zlib_image /target/usr/ /usr/
COPY --from=zstd_image /target/usr/ /usr/

COPY --from=src_image /src/ /src/
