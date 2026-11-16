ARG VERSION=5.44.0

FROM oci.badsysadm.local:80/src/perl/perl:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build
ARG VERSION

COPY debian ./debian/
RUN sed -i "1s/@VERSION@/${VERSION}/" debian/changelog
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=src_image /src /src/perl/
