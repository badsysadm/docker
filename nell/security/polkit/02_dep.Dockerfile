ARG VERSION=127

FROM oci.badsysadm.local:80/src/security/polkit:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=oci.badsysadm.local:80/bin/system/pam:1.7.2 \
    /target/usr/include/security \
    /usr/include/security

COPY --from=oci.badsysadm.local:80/bin/system/pam:1.7.2 \
    /target/usr/lib64/libpam.so.0.85.1 \
    /usr/lib/x86_64-linux-gnu/libpam.so

COPY --from=oci.badsysadm.local:80/bin/system/systemd:261 \
    /target/usr/include/systemd \
    /usr/include/systemd

COPY --from=oci.badsysadm.local:80/bin/system/systemd:261 \
    /target/usr/lib/x86_64-linux-gnu/libsystemd.so.0.44.0 \
    /usr/lib/x86_64-linux-gnu/libsystemd.so

COPY --from=oci.badsysadm.local:80/bin/system/systemd:261 \
    /target/usr/lib/x86_64-linux-gnu/pkgconfig/libsystemd.pc \
    /usr/lib/x86_64-linux-gnu/pkgconfig/libsystemd.pc

# GLib/GIO uses libmount. Use our util-linux build, which is built
# without SELinux, so static linking does not pull libselinux/libsepol.
COPY --from=oci.badsysadm.local:80/bin/utils/util-linux:2.42.2 \
    /target/usr/lib/libmount.a \
    /target/usr/lib/libblkid.a \
    /usr/lib/

COPY --from=oci.badsysadm.local:80/bin/utils/util-linux:2.42.2 \
    /target/usr/lib/pkgconfig/mount.pc \
    /target/usr/lib/pkgconfig/blkid.pc \
    /usr/lib/x86_64-linux-gnu/pkgconfig/

COPY --from=src_image /src/ /src/
