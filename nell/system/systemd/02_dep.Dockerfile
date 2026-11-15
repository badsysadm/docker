ARG VERSION=261

FROM oci.badsysadm.local:80/src/system/systemd:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=oci.badsysadm.local:80/bin/security/openssl:3.6.5 \
    /target/usr/lib64/libcrypto.a \
    /usr/lib64/
COPY --from=oci.badsysadm.local:80/bin/security/openssl:3.6.5 \
    /target/usr/lib64/libssl.a \
    /usr/lib64/
COPY --from=oci.badsysadm.local:80/bin/security/openssl:3.6.5 \
    /target/usr/lib64/pkgconfig \
    /usr/lib64/pkgconfig
COPY --from=oci.badsysadm.local:80/bin/security/openssl:3.6.5 \
    /target/usr/include/openssl \
    /usr/include/openssl

COPY --from=oci.badsysadm.local:80/bin/security/gnutls:3.8.13 \
    /target/usr/include/gnutls/ \
    /usr/include/gnutls/
COPY --from=oci.badsysadm.local:80/bin/security/gnutls:3.8.13 \
    /target/usr/lib/x86_64-linux-gnu/libgnutls.a \
    /usr/lib/x86_64-linux-gnu/libgnutls.a
COPY --from=oci.badsysadm.local:80/bin/security/gnutls:3.8.13 \
    /target/usr/lib/x86_64-linux-gnu/pkgconfig/gnutls.pc \
    /usr/lib/x86_64-linux-gnu/pkgconfig/gnutls.pc

COPY --from=src_image /src/ /src
RUN patch -d /src/systemd -p1 -i "$(pwd)/debian/patches/_gnutls-static.patch"