ARG VERSION=261

FROM oci.badsysadm.local:80/src/system/systemd:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=oci.badsysadm.local:80/bin/security/openssl:3.6.5 \
    /target/usr/lib64/libcrypto.a \
    /usr/lib64/
COPY --from=oci.badsysadm.local:80/bin/security/openssl:3.6.5 \
    /target/usr/lib64/libssl.a \
    /usr/lib64/
COPY --from=oci.badsysadm.local:80/bin/security/openssl:3.6.5 \
    /target/usr/lib64/pkgconfig \
    /usr/lib64/pkgconfig
COPY --from=oci.badsysadm.local:80/bin/security/openssl:3.6.5 \
    /target/usr/include/openssl \
    /usr/include/openssl

COPY --from=oci.badsysadm.local:80/bin/system/kmod:34.2 \
    /target/lib/x86_64-linux-gnu/libkmod.a \
    /lib/x86_64-linux-gnu/
COPY --from=oci.badsysadm.local:80/bin/system/kmod:34.2 \
    /target/lib/x86_64-linux-gnu/pkgconfig/libkmod.pc \
    /lib/x86_64-linux-gnu/pkgconfig/
COPY --from=oci.badsysadm.local:80/bin/system/kmod:34.2 \
    /target/usr/include/libkmod.h \
    /usr/include/

COPY --from=src_image /src /src/systemd/
