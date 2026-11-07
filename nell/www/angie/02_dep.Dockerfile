ARG VERSION=1.12.4
ARG OPENSSL_VERSION=3.6.5

FROM oci.badsysadm.local:80/src/www/angie:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/security/openssl:${OPENSSL_VERSION} AS openssl_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

ARG OPENSSL_VERSION

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=openssl_image /target/usr/include/openssl/ /usr/local/include/openssl/
COPY --from=openssl_image /target/usr/lib64/libssl.a /usr/local/lib64/libssl.a
COPY --from=openssl_image /target/usr/lib64/libcrypto.a /usr/local/lib64/libcrypto.a

COPY --from=src_image /src/ /src/
