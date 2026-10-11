ARG VERSION=4.9

FROM oci.badsysadm.local:80/src/net/chrony:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=oci.badsysadm.local:80/bin/lib/gnutls:3.8.13 \
    /target/usr/lib/x86_64-linux-gnu/libgnutls.a \
    /usr/lib/x86_64-linux-gnu/libgnutls.a
COPY --from=oci.badsysadm.local:80/bin/lib/gnutls:3.8.13 \
    /target/usr/lib/x86_64-linux-gnu/pkgconfig/gnutls.pc \
    /usr/lib/x86_64-linux-gnu/pkgconfig/gnutls.pc

COPY --from=src_image /src/ /src/
