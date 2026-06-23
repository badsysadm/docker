FROM mirror.gcr.io/library/debian:trixie
ARG SYSTEMD_VERSION=v261

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

RUN apt-get install -y -qq --no-install-recommends git

RUN git clone --single-branch --branch ${SYSTEMD_VERSION} --depth 1 https://github.com/systemd/systemd.git /src/systemd
WORKDIR /src/systemd

RUN meson setup build \
    --prefix=/usr \
    --libdir=/usr/lib/x86_64-linux-gnu \
    --buildtype=release \
    -Dauto_features=disabled \
    -Dacl=enabled \
    -Dapparmor=enabled \
    -Daudit=enabled \
    -Dbacklight=true \
    -Dbinfmt=true \
    -Dblkid=enabled \
    -Dbootloader=enabled \
    -Dbpf-framework=enabled \
    -Dbzip2=enabled \
    -Dcoredump=true \
    -Ddbus=enabled \
    -Defi=true \
    -Delfutils=enabled \
    -Denvironment-d=true \
    -Dfdisk=enabled \
    -Dgcrypt=enabled \
    -Dglib=enabled \
    -Dgnutls=enabled \
    -Dhibernate=true \
    -Dhomed=enabled \
    -Dhostnamed=true \
    -Dhtml=disabled \
    -Dhwdb=true \
    -Dima=true \
    -Dimportd=enabled \
    -Dipe=true \
    -Dkmod=enabled \
    -Dldconfig=true \
    -Dlibarchive=enabled \
    -Dlibcryptsetup=enabled \
    -Dlibcryptsetup-plugins=enabled \
    -Dlibcurl=enabled \
    -Dlibfido2=enabled \
    -Dlibidn2=enabled \
    -Dlibmount=enabled \
    -Dlocaled=true \
    -Dlogind=true \
    -Dlz4=enabled \
    -Dmachined=true \
    -Dman=disabled \
    -Dmicrohttpd=enabled \
    -Dmountfsd=true \
    -Dnetworkd=true \
    -Dnspawn=enabled \
    -Dnsresourced=true \
    -Dnss-myhostname=true \
    -Dnss-mymachines=enabled \
    -Dnss-resolve=enabled \
    -Dnss-systemd=true \
    -Doomd=true \
    -Dopenssl=enabled \
    -Dp11kit=enabled \
    -Dpam=enabled \
    -Dpasswdqc=enabled \
    -Dpcre2=enabled \
    -Dpolkit=enabled \
    -Dportabled=true \
    -Dpstore=true \
    -Dpwquality=enabled \
    -Dqrencode=enabled \
    -Dquotacheck=true \
    -Drandomseed=true \
    -Dremote=enabled \
    -Drepart=enabled \
    -Dresolve=true \
    -Drfkill=true \
    -Dseccomp=enabled \
    -Dselinux=enabled \
    -Dsmack=true \
    -Dstandalone-binaries=true \
    -Dstatic-libsystemd=pic \
    -Dstoragetm=true \
    -Dsysext=true \
    -Dsysupdate=enabled \
    -Dsysupdated=enabled \
    -Dsysusers=true \
    -Dtimedated=true \
    -Dtimesyncd=true \
    -Dtmpfiles=true \
    -Dtpm=true \
    -Dtpm2=enabled \
    -Dukify=enabled \
    -Duserdb=true \
    -Dutmp=true \
    -Dvconsole=true \
    -Dvmspawn=enabled \
    -Dxkbcommon=enabled \
    -Dxz=enabled \
    -Dzlib=enabled \
    -Dzstd=enabled \
    -Dxenctrl=disabled \
    -Dlibcrypt=enabled \
    -Dlink-udev-shared=true \
    -Dlink-systemctl-shared=true \
    -Dlink-networkd-shared=true \
    -Dlink-timesyncd-shared=true \
    -Dlink-journalctl-shared=true \
    -Dlink-boot-shared=true \
    -Dlink-portabled-shared=true \
    -Dsbat-distro=debian \
    -Dsbat-distro-summary="Debian" \
    -Dsbat-distro-pkgname="systemd" \
    -Dsbat-distro-url="https://www.debian.org" \
    -Dsbat-distro-version="${SYSTEMD_VERSION}"

RUN ninja -C build
RUN DESTDIR=debian/tmp ninja -C build/ install
