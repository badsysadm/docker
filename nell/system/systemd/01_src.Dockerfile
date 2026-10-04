FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=261

RUN mkdir -p /src/systemd /src/target
RUN git clone --single-branch --branch v${VERSION} --depth 1 https://github.com/systemd/systemd.git /src/systemd

FROM scratch
COPY --from=build /src/systemd/ /src
