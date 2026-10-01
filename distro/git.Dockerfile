FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG GIT_VERSION=v2.56.0
ARG OPENSSL_VERSION=openssl-3.4.0

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
        ca-certificates autoconf liblzma-dev libzstd-dev cargo tcl gettext\
    build-essential git make libcurl4-openssl-dev libexpat1-dev zlib1g-dev perl libssl-dev

RUN mkdir -p /src/target
RUN git clone --single-branch --branch ${OPENSSL_VERSION} --depth 1 https://github.com/openssl/openssl.git /src/openssl && \
    cd /src/openssl && \
    ./config no-shared no-tests --prefix=/usr/local --openssldir=/usr/local/ssl && \
    make -j$(nproc) build_libs && \
    make install_sw

RUN git clone --single-branch --branch ${GIT_VERSION} --depth 1 https://github.com/git/git.git /src/git
WORKDIR /src/git

RUN make configure
RUN ./configure --prefix=/usr
RUN sed -i 's/EXTLIBS += -lz/EXTLIBS += \/usr\/lib\/x86_64-linux-gnu\/libz.a/g' Makefile
RUN make -j$(nproc) NO_CURL=0 NO_EXPAT=0 NO_GETTEXT=1 NO_OPENSSL=0 NO_INSTALL_NLS=1 NO_TESTS=1 NO_INSTALL_HARDLINKS=0 OPENSSLDIR=/usr/local CFLAGS="-static-libgcc -I/usr/local/include" LDFLAGS="-L/usr/local/lib64 -L/usr/local/lib -Wl,-Bstatic -lssl -lcrypto -lcurl -lexpat -lzstd -llzma -Wl,-Bdynamic -lc -lpthread -ldl"
#RUN make -j$(nproc) NO_CURL=0 NO_EXPAT=0 NO_GETTEXT=1 NO_OPENSSL=0 NO_INSTALL_NLS=1 NO_TESTS=1 
RUN make install DESTDIR=/src/target NO_CURL=0 NO_EXPAT=0 NO_GETTEXT=1 NO_OPENSSL=0 NO_TESTS=1 NO_INSTALL_HARDLINKS=0 OPENSSLDIR=/usr/local
#RUN make install DESTDIR=/src/target NO_CURL=0 NO_EXPAT=0 NO_GETTEXT=1 NO_OPENSSL=0 NO_TESTS=1
RUN for i in $(ls /src/target/usr/libexec/git-core/); do strip $i; done



FROM scratch AS bundle
LABEL org.opencontainers.image.title="git"
LABEL org.opencontainers.image.version="2.56.0"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Fast, scalable, distributed revision control system"
COPY --from=build /src/target/ /
