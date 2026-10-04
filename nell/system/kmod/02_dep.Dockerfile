ARG VERSION=34.2

FROM oci.badsysadm.local:80/src/system/kmod:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=oci.badsysadm.local:80/bin/security/openssl:3.6.5 \
    /target/usr/lib64/libcrypto.a \
    /usr/local/lib64/
COPY --from=oci.badsysadm.local:80/bin/security/openssl:3.6.5 \
    /target/usr/lib64/pkgconfig/libcrypto.pc \
    /usr/local/lib64/pkgconfig/
COPY --from=oci.badsysadm.local:80/bin/security/openssl:3.6.5 \
    /target/usr/include/openssl \
    /usr/local/include/openssl

COPY --from=src_image /src/ /src