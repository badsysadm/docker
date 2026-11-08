ARG VERSION=1.8.1.3
ARG OPENSSL_VERSION=3.6.5
ARG NCURSES_VERSION=6.6

FROM oci.badsysadm.local:80/src/net/socat:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/security/openssl:${OPENSSL_VERSION} AS openssl_image
FROM oci.badsysadm.local:80/bin/lib/ncurses:${NCURSES_VERSION} AS ncurses_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=openssl_image /target/usr/include/openssl/ /usr/local/include/openssl/
COPY --from=openssl_image /target/usr/lib64/libssl.a /usr/local/lib64/libssl.a
COPY --from=openssl_image /target/usr/lib64/libcrypto.a /usr/local/lib64/libcrypto.a
COPY --from=ncurses_image /target/lib/x86_64-linux-gnu/libncursesw.a /usr/local/lib/libncursesw.a

RUN cp /usr/lib/x86_64-linux-gnu/libreadline.a \
       /usr/lib/x86_64-linux-gnu/libwrap.a \
       /usr/local/lib/

COPY --from=src_image /src/ /src/
