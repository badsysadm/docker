FROM mirror.gcr.io/library/debian:trixie
ARG VERSION=v2.42.2

RUN  apt-get update && apt-get install -y -qq --no-install-recommends \
     build-essential git pkg-config ca-certificates \
     meson ninja-build bison flex \
     libpam0g-dev libaudit-dev libsystemd-dev systemd-dev libudev-dev libcap-ng-dev libcap-dev
RUN git clone --single-branch --branch ${VERSION} --depth 1 https://github.com/util-linux/util-linux.git /src/util-linux
WORKDIR /src/util-linux

ARG LDFLAGS="-Wl,-Bstatic -lcap-ng -lcap -laudit -lsystemd -Wl,-Bdynamic"
RUN meson setup build \
    --prefix=/usr \
    --buildtype=release \
    --default-library=static \
    --wrap-mode=nodownload \
    -Dprefer_static=true \
    -Dauto_features=disabled \
    -Dbuild-plymouth-support=enabled \
    -Dpg-bell=false \
    -Dcolors-default=true \
    -Dlogin-lastlogin=true \
    -Dlogin-stat-mail=true \
    -Dprogram-tests=false \
    -Dsystemd=enabled \
    -Dbuild-login=enabled \
    -Dbuild-agetty=enabled \
    -Dbuild-nologin=enabled \
    -Dbuild-last=enabled \
    -Dbuild-kill=enabled \
    -Dbuild-dmesg=enabled \
    -Dbuild-whereis=enabled   
    
RUN ninja -C build
RUN DESTDIR=debian/tmp ninja -C build/ install
