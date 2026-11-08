ARG VERSION=7.2

FROM oci.badsysadm.local:80/src/net/ethtool:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

RUN mkdir -p /usr/local/lib && \
    cp /usr/lib/x86_64-linux-gnu/libmnl.a /usr/local/lib/

COPY --from=src_image /src/ /src/
