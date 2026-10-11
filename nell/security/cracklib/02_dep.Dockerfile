ARG VERSION=2.10.3

FROM oci.badsysadm.local:80/src/security/cracklib:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=oci.badsysadm.local:80/bin/lib/zlib:1.3.1 \
    /target/usr/include/ \
    /usr/local/include/

COPY --from=oci.badsysadm.local:80/bin/lib/zlib:1.3.1 \
    /target/usr/lib/x86_64-linux-gnu/libz.a \
    /usr/local/lib/libz.a

COPY --from=src_image /src/ /src/
