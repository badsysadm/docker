FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=4.3.0

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/buildbot/buildbot.git /src/buildbot

FROM scratch
COPY --from=build /src/ /src/
