ARG VERSION=261

FROM oci.badsysadm.local:80/dep/system/systemd:${VERSION} AS dep_image

FROM dep_image AS build
ARG VERSION
ARG SOURCE_DATE_EPOCH=1700000000
ENV SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH}

WORKDIR /src/systemd

RUN PKG_CONFIG_PATH="/usr/lib64/pkgconfig:/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig" \
    meson setup build \
    --prefix=/usr \
    --libdir=/usr/lib/x86_64-linux-gnu \
    --buildtype=release \
    -Dinstall-tests=false \
    -Drpmmacrosdir=no \
    -Dmode=release \
    -Ddev-kvm-mode=0660 \
    -Dnobody-group=nogroup \
    -Dman=disabled \
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
    -Dsbat-distro-version="${VERSION}"

RUN ninja -C build
RUN DESTDIR=/src/target ninja -C build install

RUN rm -rf /src/target/usr/share/man /src/target/usr/share/doc /src/target/usr/share/info

FROM scratch AS bundle
LABEL org.opencontainers.image.title="systemd"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="systemd bundle"
COPY --from=build /src/target/ /target/
