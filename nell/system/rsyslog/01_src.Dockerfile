FROM oci.badsysadm.local:80/get/source:latest AS build

ARG VERSION=8.2608.0
ARG CIVETWEB_VERSION=1.16
ARG ZLIB_VERSION=1.3.1
ARG CURL_VERSION=8.14.1
ARG LIBFASTJSON_VERSION=1.2609.0
ARG ZSTD_VERSION=1.5.7
ARG APR_VERSION=1.7.5
ARG APR_UTIL_VERSION=1.6.3
ARG LIBXCRYPT_VERSION=4.4.38

RUN mkdir -p /src/rsyslog /src/target && \
    wget -qO- \
        https://www.rsyslog.com/files/download/rsyslog/rsyslog-${VERSION}.tar.gz \
        | tar -xzf - -C /src/rsyslog --strip-components=1 && \
    git clone -q --single-branch \
        --branch v${CIVETWEB_VERSION} \
        --depth 1 \
        https://github.com/civetweb/civetweb.git \
        /src/civetweb && \
    git clone -q --single-branch \
        --branch v${ZLIB_VERSION} \
        --depth 1 \
        https://github.com/madler/zlib.git \
        /src/zlib && \
    mkdir -p /src/curl /src/libfastjson /src/zstd /src/apr /src/apr-util /src/libxcrypt && \
    wget -qO- \
        https://curl.se/download/curl-${CURL_VERSION}.tar.gz \
        | tar -xzf - -C /src/curl --strip-components=1 && \
    wget -qO- \
        https://github.com/rsyslog/libfastjson/releases/download/v${LIBFASTJSON_VERSION}/libfastjson-${LIBFASTJSON_VERSION}.tar.gz \
        | tar -xzf - -C /src/libfastjson --strip-components=1 && \
    wget -qO- \
        https://github.com/facebook/zstd/releases/download/v${ZSTD_VERSION}/zstd-${ZSTD_VERSION}.tar.gz \
        | tar -xzf - -C /src/zstd --strip-components=1 && \
    wget -qO- \
        https://archive.apache.org/dist/apr/apr-${APR_VERSION}.tar.gz \
        | tar -xzf - -C /src/apr --strip-components=1 && \
    wget -qO- \
        https://archive.apache.org/dist/apr/apr-util-${APR_UTIL_VERSION}.tar.gz \
        | tar -xzf - -C /src/apr-util --strip-components=1 && \
    wget -qO- \
        https://github.com/besser82/libxcrypt/releases/download/v${LIBXCRYPT_VERSION}/libxcrypt-${LIBXCRYPT_VERSION}.tar.xz \
        | tar -xJf - -C /src/libxcrypt --strip-components=1

FROM scratch
COPY --from=build /src/ /src
