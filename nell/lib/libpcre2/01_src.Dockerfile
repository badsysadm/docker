FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=10.49

RUN git clone -q --recurse-submodules --single-branch --branch "pcre2-${VERSION}" --depth 1 \
    https://github.com/PCRE2Project/pcre2.git /src/pcre2

FROM scratch
COPY --from=build /src/ /src/
