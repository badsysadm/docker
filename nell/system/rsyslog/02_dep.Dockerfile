ARG VERSION=8.2608.0

FROM oci.badsysadm.local:80/src/system/rsyslog:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=oci.badsysadm.local:80/bin/security/openssl:3.6.5 \
    /target/usr/lib64/libcrypto.a \
    /target/usr/lib64/libssl.a \
    /usr/local/lib64/

COPY --from=oci.badsysadm.local:80/bin/security/openssl:3.6.5 \
    /target/usr/include/openssl \
    /usr/local/include/openssl

COPY --from=oci.badsysadm.local:80/bin/security/openssl:3.6.5 \
    /target/usr/lib64/pkgconfig \
    /usr/local/lib64/pkgconfig

RUN sed -i \
        -e 's|^prefix=/usr$|prefix=/usr/local|' \
        -e 's|/usr/lib/x86_64-linux-gnu/libz\.a|-lz|g' \
        -e 's|/usr/lib/x86_64-linux-gnu/libzstd\.a|-lzstd|g' \
        /usr/local/lib64/pkgconfig/*.pc


COPY --from=src_image /src/ /src/

COPY debian/rsyslog.service /src/rsyslog/debian/rsyslog.service
