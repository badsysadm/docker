FROM mirror.gcr.io/library/debian:trixie
ARG BASH_VERSION=bash-5.3

RUN  apt-get update && apt-get install -y -qq --no-install-recommends \
     build-essential git pkg-config ca-certificates \
     libncurses-dev
WORKDIR /src/bash
RUN git clone --single-branch --branch ${BASH_VERSION} --depth 1 https://https.git.savannah.gnu.org/git/bash.git /src/bash
RUN ./configure \
    --prefix=/usr \
    --enable-mem-scramble \
    --enable-net-redirections \
    --enable-xpg-echo-default \
    --disable-help-builtin \
    --enable-year2038 \
    --with-bash-malloc \
    --with-curses \
    --disable-nls
RUN make
RUN make install DESTDIR=/opt/bash
