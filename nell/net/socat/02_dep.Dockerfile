ARG VERSION=1.8.1.3
ARG OPENSSL_VERSION=3.6.5
ARG NCURSES_VERSION=6.6
ARG ZLIB_VERSION=1.3.1
ARG ZSTD_VERSION=1.5.7

FROM oci.badsysadm.local:80/src/net/socat:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/security/openssl:${OPENSSL_VERSION} AS openssl_image
FROM oci.badsysadm.local:80/bin/lib/ncurses:${NCURSES_VERSION} AS ncurses_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM oci.badsysadm.local:80/bin/utils/zstd:${ZSTD_VERSION} AS zstd_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=openssl_image /target/usr/include/openssl/ /usr/local/include/openssl/
COPY --from=openssl_image /target/usr/lib64/libssl.a /usr/local/lib64/libssl.a
COPY --from=openssl_image /target/usr/lib64/libcrypto.a /usr/local/lib64/libcrypto.a
COPY --from=ncurses_image /target/usr/lib/libncursesw.a /usr/local/lib/libncursesw.a
COPY --from=zlib_image /target/usr/lib/x86_64-linux-gnu/libz.a /usr/local/lib/libz.a
COPY --from=zstd_image /target/usr/lib/libzstd.a /usr/local/lib/libzstd.a

RUN for lib in libreadline.a libwrap.a; do \
        install -D "/usr/lib/x86_64-linux-gnu/$lib" "/usr/local/lib/$lib" || exit 1; \
    done

COPY --from=src_image /src/ /src/
