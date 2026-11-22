ARG VERSION=2.42.2
ARG SQLITE_VERSION=3.54.1
ARG LIBCAP_NG_VERSION=0.8.5

FROM oci.badsysadm.local:80/src/utils/util-linux:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/lib/sqlite:${SQLITE_VERSION} AS sqlite_image
FROM oci.badsysadm.local:80/bin/lib/libcap-ng:${LIBCAP_NG_VERSION} AS libcap_ng_image
FROM oci.badsysadm.local:80/get/dep:latest AS build
ARG VERSION

COPY debian ./debian/
RUN sed -i "1s/@VERSION@/${VERSION}/" debian/changelog
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=sqlite_image /target/usr/include/ /usr/local/include/
COPY --from=sqlite_image /target/usr/lib/libsqlite3.a /usr/local/lib/libsqlite3.a
COPY --from=sqlite_image /target/usr/lib/pkgconfig/sqlite3.pc /usr/local/lib/pkgconfig/sqlite3.pc

COPY --from=libcap_ng_image /target/usr/include/ /usr/local/include/
COPY --from=libcap_ng_image /target/usr/lib/libcap-ng.a /usr/local/lib/libcap-ng.a

COPY --from=src_image /src/ /src/