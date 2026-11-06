ARG VERSION=2.2.1
ARG GO_VERSION=1.27.3

FROM oci.badsysadm.local:80/src/security/vault:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

ARG GO_VERSION

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

# Upstream pins Go independently of Debian's golang-go package.
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz \
    && tar -C /usr/local -xzf /tmp/go.tar.gz \
    && rm /tmp/go.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

COPY --from=src_image /src/ /src/
