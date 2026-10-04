FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=34.2

RUN mkdir -p /src/kmod /src/target
RUN git clone --single-branch --branch v${VERSION} --depth 1 https://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git /src/kmod

FROM scratch
COPY --from=build /src/ /src