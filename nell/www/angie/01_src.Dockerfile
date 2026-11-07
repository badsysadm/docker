FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.12.4

RUN git clone -q --single-branch --branch "Angie-${VERSION}" --depth 1 \
    https://github.com/webserver-llc/angie.git /src/angie

WORKDIR /src/angie
RUN git clone -q --depth 1 --branch v0.3.4 \
    https://github.com/vision5/ngx_devel_kit.git ngx_devel_kit
RUN git clone -q --depth 1 --branch pcre2-10.49 --recurse-submodules \
    https://github.com/PCRE2Project/pcre2.git pcre2
RUN git clone -q --depth 1 --branch v1.4 \
    https://github.com/madler/zlib.git zlib

RUN git clone -q --depth 1 --branch v0.66 \
    https://github.com/openresty/echo-nginx-module.git echo-nginx-module
RUN git clone -q --depth 1 --branch v0.34 \
    https://github.com/openresty/set-misc-nginx-module.git set-misc-nginx-module
RUN git clone -q --depth 1 --branch v0.41 \
    https://github.com/openresty/headers-more-nginx-module.git headers-more-nginx-module
RUN git clone -q --depth 1 --branch v0.07 \
    https://github.com/openresty/xss-nginx-module.git xss-nginx-module
RUN git clone -q --depth 1 --branch v0.4.0 \
    https://github.com/yaoweibin/nginx_upstream_check_module.git check_module

FROM scratch
COPY --from=build /src/ /src/
