ARG VERSION=2.1.23
ARG GO_VERSION=1.27.3
ARG ZUI_VERSION=commit-ce3819c

FROM oci.badsysadm.local:80/src/net/zot:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

ARG GO_VERSION
ARG ZUI_VERSION

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" | tar -xz -C /usr/local
RUN update-alternatives --install /usr/bin/go go /usr/local/go/bin/go 100

COPY --from=src_image /src/ /src/

WORKDIR /src/zot
RUN GOTOOLCHAIN=local go mod vendor
RUN curl -fsSL "https://github.com/project-zot/zui/releases/download/${ZUI_VERSION}/zui.tgz" \
    | tar -xz -C /src/zot/pkg/extensions/
