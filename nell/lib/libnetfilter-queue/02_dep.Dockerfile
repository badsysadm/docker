ARG VERSION=1.0.5
ARG LIBMNL_VERSION=1.0.5
ARG LIBNFNETLINK_VERSION=1.0.2

FROM oci.badsysadm.local:80/src/lib/libnetfilter-queue:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/lib/libmnl:${LIBMNL_VERSION} AS libmnl_image
FROM oci.badsysadm.local:80/bin/lib/libnfnetlink:${LIBNFNETLINK_VERSION} AS libnfnetlink_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=libmnl_image /target/usr/local/include/ /usr/local/include/
COPY --from=libmnl_image /target/usr/local/lib/libmnl.a /usr/local/lib/libmnl.a
COPY --from=libmnl_image /target/usr/local/lib/pkgconfig/ /usr/local/lib/pkgconfig/
COPY --from=libnfnetlink_image /target/usr/local/include/ /usr/local/include/
COPY --from=libnfnetlink_image /target/usr/local/lib/libnfnetlink.a /usr/local/lib/libnfnetlink.a
COPY --from=libnfnetlink_image /target/usr/local/lib/pkgconfig/ /usr/local/lib/pkgconfig/

COPY --from=src_image /src/ /src/
