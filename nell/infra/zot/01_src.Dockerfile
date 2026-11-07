FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.1.23
ARG ZUI_VERSION=commit-ce3819c

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 https://github.com/project-zot/zot.git /src/zot
RUN git clone -q --single-branch --branch "${ZUI_VERSION}" --depth 1 https://github.com/project-zot/zui.git /src/zui

FROM scratch
COPY --from=build /src/ /src/
