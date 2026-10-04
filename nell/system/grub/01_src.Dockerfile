FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.14
ARG EFIVAR_VERSION=39
ARG LVM2_VERSION=2.03.43

RUN mkdir -p /src/grub /src/efivar /src/lvm2 /src/target && \
    wget -qO- https://ftp.gnu.org/gnu/grub/grub-${VERSION}.tar.xz | tar -xJf - -C /src/grub --strip-components=1 && \
    wget -qO- https://github.com/rhboot/efivar/archive/refs/tags/${EFIVAR_VERSION}.tar.gz | tar -xzf - -C /src/efivar --strip-components=1 && \
    wget -qO- https://sourceware.org/pub/lvm2/LVM2.${LVM2_VERSION}.tgz | tar -xzf - -C /src/lvm2 --strip-components=1

FROM scratch
COPY --from=build /src/ /src
