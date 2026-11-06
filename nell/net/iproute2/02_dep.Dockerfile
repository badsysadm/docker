ARG VERSION=7.2.0
ARG ELFUTILS_VERSION=0.196

FROM oci.badsysadm.local:80/src/net/iproute2:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/utils/elfutils:${ELFUTILS_VERSION} AS elfutils_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=elfutils_image /target/usr/include/ /usr/include/
COPY --from=elfutils_image /target/usr/lib/x86_64-linux-gnu/libelf.a /usr/lib/x86_64-linux-gnu/libelf.a
COPY --from=elfutils_image /target/usr/lib/x86_64-linux-gnu/pkgconfig/libelf.pc /usr/lib/x86_64-linux-gnu/pkgconfig/libelf.pc
COPY --from=src_image /src/ /src
