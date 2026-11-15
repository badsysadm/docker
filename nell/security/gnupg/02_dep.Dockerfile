ARG VERSION=2.4.7
ARG LIBGPG_ERROR_VERSION=1.51
ARG LIBGCRYPT_VERSION=1.11.0
ARG LIBASSUAN_VERSION=3.0.2
ARG LIBKSBA_VERSION=1.6.7
ARG NPTH_VERSION=1.8
ARG ZLIB_VERSION=1.3.1
ARG BZIP2_VERSION=1.0.8

FROM oci.badsysadm.local:80/src/security/gnupg:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/lib/libgpg-error:${LIBGPG_ERROR_VERSION} AS libgpg_error_image
FROM oci.badsysadm.local:80/bin/lib/libgcrypt:${LIBGCRYPT_VERSION} AS libgcrypt_image
FROM oci.badsysadm.local:80/bin/lib/libassuan:${LIBASSUAN_VERSION} AS libassuan_image
FROM oci.badsysadm.local:80/bin/lib/libksba:${LIBKSBA_VERSION} AS libksba_image
FROM oci.badsysadm.local:80/bin/lib/npth:${NPTH_VERSION} AS npth_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM oci.badsysadm.local:80/bin/lib/bzip2:${BZIP2_VERSION} AS bzip2_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=libgpg_error_image /target/usr/lib/libgpg-error.a /usr/lib/libgpg-error.a
COPY --from=libgpg_error_image /target/usr/include/ /usr/include/
COPY --from=libgpg_error_image /target/usr/lib/pkgconfig/gpg-error.pc /usr/lib/pkgconfig/gpg-error.pc
COPY --from=libgpg_error_image /target/usr/bin/gpgrt-config /usr/bin/gpgrt-config
COPY --from=libgcrypt_image /target/usr/lib/libgcrypt.a /usr/lib/libgcrypt.a
COPY --from=libgcrypt_image /target/usr/include/ /usr/include/
COPY --from=libgcrypt_image /target/usr/lib/pkgconfig/libgcrypt.pc /usr/lib/pkgconfig/libgcrypt.pc
COPY --from=libassuan_image /target/usr/lib/libassuan.a /usr/lib/libassuan.a
COPY --from=libassuan_image /target/usr/include/ /usr/include/
COPY --from=libassuan_image /target/usr/lib/pkgconfig/libassuan.pc /usr/lib/pkgconfig/libassuan.pc
COPY --from=libksba_image /target/usr/lib/libksba.a /usr/lib/libksba.a
COPY --from=libksba_image /target/usr/include/ /usr/include/
COPY --from=libksba_image /target/usr/lib/pkgconfig/ksba.pc /usr/lib/pkgconfig/ksba.pc
COPY --from=npth_image /target/usr/lib/libnpth.a /usr/lib/libnpth.a
COPY --from=npth_image /target/usr/include/ /usr/include/
COPY --from=npth_image /target/usr/lib/pkgconfig/npth.pc /usr/lib/pkgconfig/npth.pc

COPY --from=zlib_image /target/usr/lib/x86_64-linux-gnu/libz.a /usr/lib/libz.a
COPY --from=zlib_image /target/usr/include/zlib.h /usr/include/zlib.h
COPY --from=zlib_image /target/usr/include/zconf.h /usr/include/zconf.h
COPY --from=bzip2_image /target/usr/lib/libbz2.a /usr/lib/libbz2.a
COPY --from=bzip2_image /target/usr/include/bzlib.h /usr/include/bzlib.h

COPY --from=src_image /src/ /src/
