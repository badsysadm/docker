ARG VERSION=0.1.0

FROM oci.badsysadm.local:80/src/dev/dpkg-cvecheck:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY --from=src_image /src/ /src/
WORKDIR /src/dpkg-cvecheck
COPY debian/ ./debian/

RUN apt-get -qq update && \
    mk-build-deps --install --remove \
        --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' \
        debian/control

RUN make get
