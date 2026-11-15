ARG VERSION=4.9

FROM oci.badsysadm.local:80/src/net/chrony:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=oci.badsysadm.local:80/bin/security/gnutls:3.8.13 \
    /target/usr/include/gnutls/ \
    /usr/include/gnutls/

COPY --from=oci.badsysadm.local:80/bin/security/gnutls:3.8.13 \
    /target/usr/lib/libgnutls.a \
    /usr/lib/libgnutls.a
COPY --from=oci.badsysadm.local:80/bin/security/gnutls:3.8.13 \
    /target/usr/lib/pkgconfig/gnutls.pc \
    /usr/lib/pkgconfig/gnutls.pc

COPY --from=src_image /src/ /src/
