ARG VERSION=3.3.7

FROM oci.badsysadm.local:80/src/system/apt:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build
ARG VERSION

COPY debian ./debian/
RUN sed -i "1s/@VERSION@/${VERSION}/" debian/changelog

RUN echo "deb http://deb.debian.org/debian trixie-backports main" \
    > /etc/apt/sources.list.d/trixie-backports.list

RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

RUN apt-get install -y -t trixie-backports cmake

COPY --from=src_image /src/ /src
