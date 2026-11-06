ARG VERSION=4.1.8
FROM oci.badsysadm.local:80/src/security/apparmor:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build
COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control
COPY --from=src_image /src/ /src/
