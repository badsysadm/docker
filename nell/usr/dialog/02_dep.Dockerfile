ARG VERSION=1.3-20260721
ARG NCURSES_VERSION=6.6

FROM oci.badsysadm.local:80/src/usr/dialog:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/lib/ncurses:${NCURSES_VERSION} AS ncurses_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=ncurses_image /target/usr/include/ /usr/local/include/
COPY --from=ncurses_image /target/usr/lib/ /usr/local/lib/

COPY --from=src_image /src/ /src