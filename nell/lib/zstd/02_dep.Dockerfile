ARG VERSION=1.5.7
ARG ZLIB_VERSION=1.3.1
ARG XZUTILS_VERSION=5.6.2

FROM oci.badsysadm.local:80/src/lib/zstd:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM oci.badsysadm.local:80/bin/utils/xzutils:${XZUTILS_VERSION} AS xzutils_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=zlib_image /target/usr/include/zlib.h /usr/local/include/zlib.h
COPY --from=zlib_image /target/usr/include/zconf.h /usr/local/include/zconf.h
COPY --from=zlib_image /target/usr/lib/x86_64-linux-gnu/libz.a /usr/local/lib/libz.a

COPY --from=xzutils_image /target/usr/include/lzma.h /usr/local/include/lzma.h
COPY --from=xzutils_image /target/usr/include/lzma/ /usr/local/include/lzma/
COPY --from=xzutils_image /target/usr/lib/x86_64-linux-gnu/liblzma.a /usr/local/lib/liblzma.a

COPY --from=src_image /src/ /src/
