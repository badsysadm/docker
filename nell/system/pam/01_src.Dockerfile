FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.7.2

RUN mkdir -p /src/pam /src/target && \
    wget -qO- https://github.com/linux-pam/linux-pam/releases/download/v${VERSION}/Linux-PAM-${VERSION}.tar.xz | tar -xJf - -C /src/pam --strip-components=1

FROM scratch
COPY --from=build /src/ /src
