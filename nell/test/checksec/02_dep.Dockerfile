ARG VERSION=3.2.0
ARG GO_VERSION=1.27.3

FROM oci.badsysadm.local:80/src/test/checksec:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

ARG GO_VERSION

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" | tar -xz -C /usr/local
RUN update-alternatives --install /usr/bin/go go /usr/local/go/bin/go 100

COPY --from=src_image /src/ /src/

WORKDIR /src/checksec
RUN GOTOOLCHAIN=local go mod vendor
