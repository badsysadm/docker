ARG VERSION=1.0

FROM oci.badsysadm.local:80/src/dev/autopoint:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/dev/gettext:${VERSION} AS gettext_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=gettext_image /target/usr/bin/autopoint /usr/bin/autopoint
COPY --from=gettext_image /target/usr/share/gettext/ /usr/share/gettext/
COPY --from=src_image /src/ /src/
