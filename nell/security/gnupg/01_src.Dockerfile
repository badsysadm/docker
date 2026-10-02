FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.4.7

RUN git clone --single-branch --branch "gnupg-${GNUPG_VERSION}" --depth 1 https://dev.gnupg.org/source/gnupg.git /src/gnupg

FROM scratch
COPY --from=build /src/gnupg/ /src
