FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=5.3

RUN git clone -q --single-branch --branch "bash-${VERSION}" --depth 1 https://git.savannah.gnu.org/git/bash.git /src/bash

FROM scratch
COPY --from=build /src/ /src
