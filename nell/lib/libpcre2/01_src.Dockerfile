FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=10.49

RUN git clone -q --single-branch --branch "pcre2-10.49" --depth 1 \
    https://github.com/PCRE2Project/pcre2.git /src/pcre2

FROM scratch
COPY --from=build /src/ /src/
