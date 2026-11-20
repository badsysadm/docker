ARG VERSION=1.0.145

FROM oci.badsysadm.local:80/src/dev/debootstrap:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build
ARG VERSION

WORKDIR /src/debootstrap
COPY --from=src_image /src/debootstrap/ /src/debootstrap/
COPY debian ./debian/
RUN sed -i "1s/@VERSION@/${VERSION}/" debian/changelog
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control
