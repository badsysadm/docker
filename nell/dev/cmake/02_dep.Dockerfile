ARG VERSION=4.4.5
ARG OPENSSL_VERSION=3.6.5
ARG ZLIB_VERSION=1.3.1
ARG ZSTD_VERSION=1.5.7

FROM oci.badsysadm.local:80/src/dev/cmake:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/security/openssl:${OPENSSL_VERSION} AS openssl_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM oci.badsysadm.local:80/bin/utils/zstd:${ZSTD_VERSION} AS zstd_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=openssl_image /target/usr/include/openssl/ /usr/local/include/openssl/
COPY --from=openssl_image /target/usr/lib64/libssl.a /usr/local/lib/libssl.a
COPY --from=openssl_image /target/usr/lib64/libcrypto.a /usr/local/lib/libcrypto.a
COPY --from=openssl_image /target/usr/lib64/pkgconfig/ /usr/local/lib/pkgconfig/
RUN sed -i \
    -e 's|^prefix=.*|prefix=/usr/local|' \
    -e 's|^libdir=.*|libdir=${exec_prefix}/lib|' \
    /usr/local/lib/pkgconfig/*.pc

COPY --from=zlib_image /target/usr/include/zlib.h /usr/local/include/zlib.h
COPY --from=zlib_image /target/usr/include/zconf.h /usr/local/include/zconf.h
COPY --from=zlib_image /target/usr/lib/x86_64-linux-gnu/libz.a /usr/local/lib/libz.a

COPY --from=zstd_image /target/usr/include/zstd.h /usr/local/include/zstd.h
COPY --from=zstd_image /target/usr/include/zstd_errors.h /usr/local/include/zstd_errors.h
COPY --from=zstd_image /target/usr/lib/libzstd.a /usr/local/lib/libzstd.a

COPY --from=src_image /src/ /src/
