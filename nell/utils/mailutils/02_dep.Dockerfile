ARG VERSION=3.21

FROM oci.badsysadm.local:80/src/utils/mailutils:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=oci.badsysadm.local:80/bin/security/gnutls:3.8.13 \
    /target/usr/include/gnutls/ \
    /usr/include/gnutls/
COPY --from=oci.badsysadm.local:80/bin/security/gnutls:3.8.13 \
    /target/usr/lib/x86_64-linux-gnu/libgnutls.a \
    /usr/lib/x86_64-linux-gnu/libgnutls.a
COPY --from=oci.badsysadm.local:80/bin/security/gnutls:3.8.13 \
    /target/usr/lib/x86_64-linux-gnu/pkgconfig/gnutls.pc \
    /usr/lib/x86_64-linux-gnu/pkgconfig/gnutls.pc

COPY --from=src_image /src/ /src/
