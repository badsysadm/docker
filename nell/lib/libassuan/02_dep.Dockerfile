ARG VERSION=3.0.2
ARG LIBGPG_ERROR_VERSION=1.51

FROM oci.badsysadm.local:80/src/lib/libassuan:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/lib/libgpg-error:${LIBGPG_ERROR_VERSION} AS libgpg_error_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=libgpg_error_image /target/usr/lib/libgpg-error.a /usr/lib/libgpg-error.a
COPY --from=libgpg_error_image /target/usr/include/ /usr/include/
COPY --from=libgpg_error_image /target/usr/lib/pkgconfig/gpg-error.pc /usr/lib/pkgconfig/gpg-error.pc
COPY --from=libgpg_error_image /target/usr/bin/gpgrt-config /usr/bin/gpgrt-config

COPY --from=src_image /src/ /src/
