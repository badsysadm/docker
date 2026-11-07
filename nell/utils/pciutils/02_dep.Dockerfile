ARG VERSION=3.15.0

FROM oci.badsysadm.local:80/src/utils/pciutils:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=oci.badsysadm.local:80/bin/system/kmod:34.2 \
    /target/lib/x86_64-linux-gnu/libkmod.a \
    /usr/lib/x86_64-linux-gnu/libkmod.a
COPY --from=oci.badsysadm.local:80/bin/system/systemd:261 \
    /target/usr/lib/x86_64-linux-gnu/libudev.a \
    /usr/lib/x86_64-linux-gnu/libudev.a

COPY --from=src_image /src/ /src/
