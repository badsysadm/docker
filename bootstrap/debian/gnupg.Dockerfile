FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG GNUPG_VERSION=gnupg-2.4.7
ARG LIBGPG_ERROR_VERSION=libgpg-error-1.51
ARG LIBGCRYPT_VERSION=libgcrypt-1.11.0
ARG LIBASSUAN_VERSION=libassuan-3.0.2
ARG LIBKSBA_VERSION=libksba-1.6.7
ARG NPTH_VERSION=npth-1.8

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential pkg-config git ca-certificates gettext texinfo \
    autoconf automake libtool autopoint bison fig2dev imagemagick librsvg2-bin \
    bzip2 zlib1g-dev libbz2-dev

RUN mkdir -p /src/target
WORKDIR /src

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

# 6. Клонируем GnuPG
RUN git clone --single-branch --branch ${GNUPG_VERSION} --depth 1 https://dev.gnupg.org/source/gnupg.git /src/gnupg
WORKDIR /src/gnupg

# ПАТЧ РЕПОЗИТОРИЯ: Заменяем только zlib и bzip2 на пути к архивным .a файлам
RUN sed -i 's/ZLIBS="-lz"/ZLIBS="\/usr\/lib\/x86_64-linux-gnu\/libz.a"/g' configure.ac
RUN sed -i 's/ZLIBS="$ZLIBS -lbz2"/ZLIBS="$ZLIBS \/usr\/lib\/x86_64-linux-gnu\/libbz2.a"/g' configure.ac

RUN ./autogen.sh

RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-nls \
    --disable-scdaemon \
    --disable-gpgsm \
    --disable-dirmngr \
    --enable-maintainer-mode \
    --with-libgpg-error-prefix=/usr/local \
    --with-libgcrypt-prefix=/usr/local \
    --with-libassuan-prefix=/usr/local \
    --with-libksba-prefix=/usr/local \
    --with-npth-prefix=/usr/local \
    CFLAGS="-O2" \
    LDFLAGS="-static-libgcc -static-libstdc++"

RUN make
RUN make install DESTDIR=/src/target

FROM scratch AS bundle
LABEL org.opencontainers.image.title="gnupg"
LABEL org.opencontainers.image.version="2.4.7"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Cryptographic software suite"
COPY --from=build /src/target/ /
