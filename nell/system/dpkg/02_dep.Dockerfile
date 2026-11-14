ARG VERSION=1.22.11
ARG ZLIB_VERSION=1.3.1
ARG ZSTD_VERSION=1.5.7
ARG XZUTILS_VERSION=5.6.2
ARG LIBLZ4_VERSION=1.10.0
ARG LIBBZ2_VERSION=1.0.8
ARG LIBMD_VERSION=1.3.0

FROM oci.badsysadm.local:80/src/system/dpkg:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM oci.badsysadm.local:80/bin/utils/zstd:${ZSTD_VERSION} AS zstd_image
FROM oci.badsysadm.local:80/bin/utils/xzutils:${XZUTILS_VERSION} AS xzutils_image
FROM oci.badsysadm.local:80/bin/lib/liblz4:${LIBLZ4_VERSION} AS liblz4_image
FROM oci.badsysadm.local:80/bin/lib/libbz2:${LIBBZ2_VERSION} AS libbz2_image
FROM oci.badsysadm.local:80/bin/lib/libmd:${LIBMD_VERSION} AS libmd_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=zlib_image /target/usr/include/ /usr/local/include/
COPY --from=zlib_image /target/usr/lib/x86_64-linux-gnu/libz.a /usr/local/lib/libz.a
COPY --from=zstd_image /target/usr/include/ /usr/local/include/
COPY --from=zstd_image /target/usr/lib/libzstd.a /usr/local/lib/libzstd.a
COPY --from=xzutils_image /target/usr/include/lzma.h /usr/local/include/lzma.h
COPY --from=xzutils_image /target/usr/include/lzma/ /usr/local/include/lzma/
COPY --from=xzutils_image /target/usr/lib/x86_64-linux-gnu/liblzma.a /usr/local/lib/liblzma.a
COPY --from=liblz4_image /target/usr/include/ /usr/local/include/
COPY --from=liblz4_image /target/usr/lib/liblz4.a /usr/local/lib/liblz4.a
COPY --from=libbz2_image /target/usr/include/bzlib.h /usr/local/include/bzlib.h
COPY --from=libbz2_image /target/usr/lib/libbz2.a /usr/local/lib/libbz2.a
COPY --from=libmd_image /target/usr/include/ /usr/local/include/
COPY --from=libmd_image /target/usr/lib/libmd.a /usr/local/lib/libmd.a

COPY --from=src_image /src/ /src
