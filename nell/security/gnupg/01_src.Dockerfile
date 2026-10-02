FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.4.7

RUN git clone -q --single-branch --branch "gnupg-${VERSION}" --depth 1 https://github.com/gpg/gnupg.git /src/gnupg

FROM scratch
COPY --from=build /src/gnupg/ /src
