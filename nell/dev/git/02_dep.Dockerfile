ARG VERSION=2.56.0
ARG CURL_VERSION=8.23.0
ARG OPENSSL_VERSION=3.6.5
ARG ZLIB_VERSION=1.3.1
ARG ZSTD_VERSION=1.5.7

FROM oci.badsysadm.local:80/src/dev/git:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/net/curl:${CURL_VERSION} AS curl_image
FROM oci.badsysadm.local:80/dep/net/curl:${CURL_VERSION} AS curl_dep_image
FROM oci.badsysadm.local:80/bin/security/openssl:${OPENSSL_VERSION} AS openssl_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM oci.badsysadm.local:80/bin/utils/zstd:${ZSTD_VERSION} AS zstd_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=curl_image /target/usr/include/curl/ /usr/local/include/curl/
COPY --from=curl_image /target/usr/lib/libcurl.a /usr/local/lib/libcurl.a
COPY --from=curl_image /target/usr/bin/curl-config /usr/local/bin/curl-config
COPY --from=curl_dep_image /usr/local/lib/libssh2.a /usr/local/lib/libssh2.a
COPY --from=curl_dep_image /usr/local/lib/libnghttp2.a /usr/local/lib/libnghttp2.a

COPY --from=openssl_image /target/usr/include/openssl/ /usr/local/include/openssl/
COPY --from=openssl_image /target/usr/lib64/libssl.a /usr/local/lib64/libssl.a
COPY --from=openssl_image /target/usr/lib64/libcrypto.a /usr/local/lib64/libcrypto.a

COPY --from=zlib_image /target/usr/include/zlib.h /usr/local/include/zlib.h
COPY --from=zlib_image /target/usr/include/zconf.h /usr/local/include/zconf.h
COPY --from=zlib_image /target/usr/lib/x86_64-linux-gnu/libz.a /usr/local/lib/libz.a

COPY --from=zstd_image /target/usr/lib/libzstd.a /usr/local/lib/libzstd.a

COPY --from=src_image /src/ /src/
