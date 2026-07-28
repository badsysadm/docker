FROM mirror.gcr.io/library/debian:trixie
ARG ZFS_VERSION=zfs-2.4.3
ARG OPENSSL_VERSION=openssl-3.4.1
ARG SYSTEMD_VERSION=v261.1

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    alien autoconf automake build-essential dkms gawk git \
    libaio-dev libattr1-dev libblkid-dev libelf-dev libffi-dev libpam0g-dev libtirpc-dev libtool libudev-dev uuid-dev zlib1g-dev \
    git ca-certificates perl

RUN git clone --single-branch --branch ${OPENSSL_VERSION} --depth 1 https://git.badsysadm.com/badsysadm/openssl.git /src/openssl
WORKDIR /src/openssl

RUN ./config no-shared no-tests --prefix=/usr/local
RUN make -j$(nproc)
RUN make build_libs
RUN make install_sw

RUN  apt-get update && apt-get install -y -qq --no-install-recommends \
     build-essential meson ninja-build pkg-config \
     libacl1-dev libapparmor-dev libaudit-dev libblkid-dev libcap-dev \
     libcryptsetup-dev libcurl4-openssl-dev libdw-dev libelf-dev \
     libfido2-dev libgcrypt20-dev libglib2.0-dev libgnutls28-dev \
     libidn2-dev libiptc-dev libkmod-dev liblz4-dev liblzma-dev \
     libmicrohttpd-dev libmount-dev libnss3-dev libp11-kit-dev \
     libpam0g-dev libpasswdqc-dev libpcre2-dev libpwquality-dev \
     libqrencode-dev libseccomp-dev libselinux1-dev libssl-dev \
     libtss2-dev libxkbcommon-dev libzstd-dev zlib1g-dev \
     python3-pefile python3-jinja2 python3-pyelftools \
     gperf quota xsltproc docbook-xsl python3-pip \
     libarchive-dev libfdisk-dev libbpf-dev clang bpftool \
     libcrypt-dev libdbus-1-dev

RUN git clone --single-branch --branch ${SYSTEMD_VERSION} --depth 1 https://git.badsysadm.com/badsysadm/systemd.git /src/systemd

WORKDIR /src/systemd
RUN meson setup build/ \
  -Dstatic-libsystemd=true \
  -Dstatic-libudev=true

RUN meson setup build \
    --prefix=/usr \
    --libdir=/usr/lib/x86_64-linux-gnu \
    --buildtype=release \
    -Dauto_features=disabled \
    -Dacl=disabled \
    -Dapparmor=disabled \
    -Daudit=disabled \
    -Dbacklight=true \
    -Dbinfmt=true \
    -Dblkid=enabled \
    -Dbootloader=disabled \
    -Dbpf-framework=disabled \
    -Dbzip2=enabled \
    -Dcoredump=false \
    -Ddbus=disabled \
    -Defi=true \
    -Delfutils=enabled \
    -Denvironment-d=true \
    -Dfdisk=disabled \
    -Dgcrypt=disabled \
    -Dglib=enabled \
    -Dgnutls=enabled \
    -Dhibernate=false \
    -Dhomed=disabled \
    -Dhostnamed=false \
    -Dhtml=disabled \
    -Dhwdb=true \
    -Dima=false \
    -Dimportd=disabled \
    -Dipe=true \
    -Dkmod=enabled \
    -Dldconfig=true \
    -Dlibarchive=enabled \
    -Dlibcryptsetup=enabled \
    -Dlibcryptsetup-plugins=enabled \
    -Dlibcurl=disabled \
    -Dlibfido2=disabled \
    -Dlibidn2=disabled \
    -Dlibmount=enabled \
    -Dlocaled=false \
    -Dlogind=false \
    -Dlz4=enabled \
    -Dmachined=false \
    -Dman=disabled \
    -Dmicrohttpd=disabled \
    -Dmountfsd=false \
    -Dnetworkd=false \
    -Dnspawn=disabled \
    -Dnsresourced=false \
    -Dnss-myhostname=false \
    -Dnss-mymachines=disabled \
    -Dnss-resolve=disabled \
    -Dnss-systemd=false \
    -Doomd=false \
    -Dopenssl=enabled \
    -Dp11kit=disabled \
    -Dpam=disabled \
    -Dpasswdqc=disabled \
    -Dpcre2=disabled \
    -Dpolkit=disabled \
    -Dportabled=false \
    -Dpstore=false \
    -Dpwquality=disabled \
    -Dqrencode=disabled \
    -Dquotacheck=false \
    -Drandomseed=false \
    -Dremote=disabled \
    -Drepart=disabled \
    -Dresolve=false \
    -Drfkill=true \
    -Dseccomp=enabled \
    -Dselinux=enabled \
    -Dsmack=true \
    -Dstandalone-binaries=true \
    -Dstatic-libsystemd=pic \
    -Dstoragetm=true \
    -Dsysext=false \
    -Dsysupdate=disabled \
    -Dsysupdated=disabled \
    -Dsysusers=false \
    -Dtimedated=false \
    -Dtimesyncd=false \
    -Dtmpfiles=false \
    -Dtpm=false \
    -Dtpm2=disabled \
    -Dukify=disabled \
    -Duserdb=false \
    -Dutmp=false \
    -Dvconsole=false \
    -Dvmspawn=disabled \
    -Dxkbcommon=disabled \
    -Dxz=disabled \
    -Dzlib=disabled \
    -Dzstd=disabled \
    -Dxenctrl=disabled \
    -Dlibcrypt=disabled \
    -Dlink-udev-shared=false \
    -Dlink-systemctl-shared=false \
    -Dlink-networkd-shared=false \
    -Dlink-timesyncd-shared=false \
    -Dlink-journalctl-shared=false \
    -Dlink-boot-shared=false \
    -Dlink-portabled-shared=false \
    -Dsbat-distro=debian \
    -Dsbat-distro-summary="Debian" \
    -Dsbat-distro-pkgname="systemd" \
    -Dsbat-distro-url="https://www.debian.org" \
    -Dsbat-distro-version="${SYSTEMD_VERSION}"
RUN ninja -C build/ install

RUN git clone --single-branch --branch ${ZFS_VERSION} --depth 1 https://git.badsysadm.com/badsysadm/zfs.git /src/zfs
WORKDIR /src/zfs

RUN sh ./autogen.sh

#RUN echo '#define ZFS_META_GITREV "1"' > zfs_gitrev.h
RUN ./configure --with-config=user --disable-nls --disable-sysvinit --enable-systemd --enable-pam --disable-pyzfs 

ENV LDFLAGS="-all-static -Wl,--allow-multiple-definition"
ENV LIBS="-lzstd -lz -lcrypto"

RUN make -j$(nproc)
#RUN make LDFLAGS="-all-static -Wl,--allow-multiple-definition -lzstd" -s -j$(nproc)
