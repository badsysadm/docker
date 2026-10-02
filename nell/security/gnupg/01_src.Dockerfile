FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.4.7

RUN git clone -q --single-branch --branch "gnupg-${VERSION}" --depth 1 https://github.com/gpg/gnupg.git /src/gnupg

ARG LIBGPG_ERROR_VERSION=libgpg-error-1.51
ARG LIBGCRYPT_VERSION=libgcrypt-1.11.0
ARG LIBASSUAN_VERSION=libassuan-3.0.2
ARG LIBKSBA_VERSION=libksba-1.6.7
ARG NPTH_VERSION=npth-1.8

RUN git clone -q --single-branch --branch ${LIBGPG_ERROR_VERSION} --depth 1 https://github.com/gpg/libgpg-error.git /src/libgpg-error
RUN git clone -q --single-branch --branch ${LIBGCRYPT_VERSION} --depth 1 https://github.com/gpg/libgcrypt.git /src/libgcrypt
RUN git clone -q --single-branch --branch ${LIBASSUAN_VERSION} --depth 1 https://github.com/gpg/libassuan.git /src/libassuan
RUN git clone -q --single-branch --branch ${LIBKSBA_VERSION} --depth 1 https://github.com/gpg/libksba.git /src/libksba
RUN git clone -q --single-branch --branch ${NPTH_VERSION} --depth 1 https://github.com/gpg/npth.git /src/npth

FROM scratch
COPY --from=build /src/gnupg/ /src
