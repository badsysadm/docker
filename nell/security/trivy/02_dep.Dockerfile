ARG VERSION=0.76.2
ARG GO_VERSION=1.27.3

FROM oci.badsysadm.local:80/src/security/trivy:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build
ARG VERSION

ARG GO_VERSION

COPY debian ./debian/
RUN sed -i "1s/@VERSION@/${VERSION}/" debian/changelog
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" | tar -xz -C /usr/local
RUN update-alternatives --install /usr/bin/go go /usr/local/go/bin/go 100

COPY --from=src_image /src/ /src/

WORKDIR /src/trivy
RUN GOTOOLCHAIN=local go mod vendor
