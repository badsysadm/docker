FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=5.6.2

RUN git clone --single-branch --branch v${VERSION} --depth 1 https://github.com/tukaani-project/xz.git /src/xzutils
RUN mkdir -p /src/xzutils/.build /src/target

FROM scratch
COPY --from=build /src/xzutils/ /src
