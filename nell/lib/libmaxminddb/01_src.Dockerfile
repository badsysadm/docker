FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.14.1

RUN git clone -q --single-branch --branch "${VERSION}" --depth 1 \
    https://github.com/maxmind/libmaxminddb.git /src/libmaxminddb

FROM scratch
COPY --from=build /src/ /src/
