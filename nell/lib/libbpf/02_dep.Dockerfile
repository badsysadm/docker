ARG VERSION=1.8.0

FROM oci.badsysadm.local:80/src/lib/libbpf:${VERSION} AS src_image
ARG ELFUTILS_VERSION=0.196
ARG ZLIB_VERSION=1.3.1
FROM oci.badsysadm.local:80/bin/utils/elfutils:${ELFUTILS_VERSION} AS elfutils_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=elfutils_image /target/usr/include/ /usr/local/include/
COPY --from=elfutils_image /target/usr/lib/x86_64-linux-gnu/libelf.a /usr/local/lib/libelf.a
COPY --from=elfutils_image /target/usr/lib/x86_64-linux-gnu/pkgconfig/libelf.pc /usr/local/lib/pkgconfig/libelf.pc
COPY --from=zlib_image /target/usr/include/ /usr/local/include/
COPY --from=zlib_image /target/usr/lib/x86_64-linux-gnu/libz.a /usr/local/lib/libz.a
COPY --from=zlib_image /target/usr/lib/x86_64-linux-gnu/pkgconfig/zlib.pc /usr/local/lib/pkgconfig/zlib.pc
RUN sed -i 's|^libdir=.*|libdir=/usr/local/lib|' \
    /usr/local/lib/pkgconfig/libelf.pc \
    /usr/local/lib/pkgconfig/zlib.pc

COPY --from=src_image /src/ /src/
