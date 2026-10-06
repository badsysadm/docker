ARG VERSION=1.9.17p2

FROM oci.badsysadm.local:80/src/system/sudo:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=oci.badsysadm.local:80/bin/system/pam:1.7.2 \
    /target/usr/include/security \
    /usr/include/security

COPY --from=oci.badsysadm.local:80/bin/system/pam:1.7.2 \
    /target/usr/lib64/libpam.so \
    /target/usr/lib64/libpam.so.0 \
    /target/usr/lib64/libpam.so.0.85.1 \
    /usr/lib64/

COPY --from=src_image /src/ /src
