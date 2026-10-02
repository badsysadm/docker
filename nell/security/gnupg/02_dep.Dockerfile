ARG VERSION=2.4.7

FROM oci.badsysadm.local:80/src/utils/gnupg:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

ARG LIBGPG_ERROR_VERSION=libgpg-error-1.51
ARG LIBGCRYPT_VERSION=libgcrypt-1.11.0
ARG LIBASSUAN_VERSION=libassuan-3.0.2
ARG LIBKSBA_VERSION=libksba-1.6.7
ARG NPTH_VERSION=npth-1.8

# 1. Клонируем и собираем libgpg-error статически
RUN git clone --single-branch --branch ${LIBGPG_ERROR_VERSION} --depth 1 https://dev.gnupg.org/source/libgpg-error.git /src/libgpg-error
WORKDIR /src/libgpg-error
RUN ./autogen.sh
RUN ./configure --prefix=/usr/local --enable-static --disable-shared --enable-maintainer-mode
RUN make
RUN make install

# 2. Клонируем и собираем libgcrypt статически
RUN git clone --single-branch --branch ${LIBGCRYPT_VERSION} --depth 1 https://dev.gnupg.org/source/libgcrypt.git /src/libgcrypt
WORKDIR /src/libgcrypt
RUN ./autogen.sh
RUN ./configure --prefix=/usr/local --enable-static --disable-shared --enable-maintainer-mode --with-libgpg-error-prefix=/usr/local
RUN make
RUN make install

# 3. Клонируем и собираем libassuan статически
RUN git clone --single-branch --branch ${LIBASSUAN_VERSION} --depth 1 https://dev.gnupg.org/source/libassuan.git /src/libassuan
WORKDIR /src/libassuan
RUN ./autogen.sh
RUN ./configure --prefix=/usr/local --enable-static --disable-shared --enable-maintainer-mode --with-libgpg-error-prefix=/usr/local
RUN make
RUN make install

# 4. Клонируем и собираем libksba статически
RUN git clone --single-branch --branch ${LIBKSBA_VERSION} --depth 1 https://dev.gnupg.org/source/libksba.git /src/libksba
WORKDIR /src/libksba
RUN ./autogen.sh
RUN ./configure --prefix=/usr/local --enable-static --disable-shared --enable-maintainer-mode --with-libgpg-error-prefix=/usr/local
RUN make
RUN make install

# 5. Клонируем и собираем npth статически
RUN git clone --single-branch --branch ${NPTH_VERSION} --depth 1 https://dev.gnupg.org/source/npth.git /src/npth
WORKDIR /src/npth
RUN ./autogen.sh
RUN ./configure --prefix=/usr/local --enable-static --disable-shared --enable-maintainer-mode
RUN make
RUN make install

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=src_image /src /src/gnupg/
