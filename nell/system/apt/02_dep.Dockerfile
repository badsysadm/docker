ARG VERSION=3.3.8
ARG OPENSSL_VERSION=3.6.5
ARG ZLIB_VERSION=1.3.1
ARG ZSTD_VERSION=1.5.7
ARG XZUTILS_VERSION=5.6.2
ARG BZIP2_VERSION=1.0.8
ARG LIBLZ4_VERSION=1.10.0
ARG LIBXXHASH_VERSION=0.8.3

FROM oci.badsysadm.local:80/src/system/apt:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/security/openssl:${OPENSSL_VERSION} AS openssl_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM oci.badsysadm.local:80/bin/utils/zstd:${ZSTD_VERSION} AS zstd_image
FROM oci.badsysadm.local:80/bin/utils/xzutils:${XZUTILS_VERSION} AS xzutils_image
FROM oci.badsysadm.local:80/bin/lib/bzip2:${BZIP2_VERSION} AS bzip2_image
FROM oci.badsysadm.local:80/bin/lib/liblz4:${LIBLZ4_VERSION} AS liblz4_image
FROM oci.badsysadm.local:80/bin/lib/libxxhash:${LIBXXHASH_VERSION} AS xxhash_image
FROM oci.badsysadm.local:80/get/dep:latest AS build
ARG VERSION
COPY debian ./debian/
RUN sed -i "1s/@VERSION@/${VERSION}/" debian/changelog

RUN echo "deb http://deb.debian.org/debian trixie-backports main" \
    > /etc/apt/sources.list.d/trixie-backports.list

RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

RUN apt-get install -y -t trixie-backports cmake

COPY --from=openssl_image /target/usr/include/openssl/ /usr/local/include/openssl/
COPY --from=openssl_image /target/usr/lib64/libssl.a /usr/local/lib64/libssl.a
COPY --from=openssl_image /target/usr/lib64/libcrypto.a /usr/local/lib64/libcrypto.a

COPY --from=zlib_image /target/usr/include/zlib.h /usr/local/include/zlib.h
COPY --from=zlib_image /target/usr/include/zconf.h /usr/local/include/zconf.h
COPY --from=zlib_image /target/usr/lib/x86_64-linux-gnu/libz.a /usr/local/lib/libz.a
COPY --from=zstd_image /target/usr/include/ /usr/local/include/
COPY --from=zstd_image /target/usr/lib/libzstd.a /usr/local/lib/libzstd.a
COPY --from=xzutils_image /target/usr/include/lzma.h /usr/local/include/lzma.h
COPY --from=xzutils_image /target/usr/include/lzma/ /usr/local/include/lzma/
COPY --from=xzutils_image /target/usr/lib/x86_64-linux-gnu/liblzma.a /usr/local/lib/liblzma.a
COPY --from=bzip2_image /target/usr/include/bzlib.h /usr/local/include/bzlib.h
COPY --from=bzip2_image /target/usr/lib/libbz2.a /usr/local/lib/libbz2.a
COPY --from=liblz4_image /target/usr/include/ /usr/local/include/
COPY --from=liblz4_image /target/usr/lib/liblz4.a /usr/local/lib/liblz4.a
COPY --from=xxhash_image /target/usr/include/xxhash.h /usr/local/include/xxhash.h
COPY --from=xxhash_image /target/usr/lib/libxxhash.a /usr/local/lib/libxxhash.a

COPY --from=src_image /src/ /src
