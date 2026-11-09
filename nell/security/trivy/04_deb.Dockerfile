ARG VERSION=0.76.2
ARG CVECHECK_VERSION=0.1.0

FROM oci.badsysadm.local:80/bin/security/trivy:${VERSION} AS bin_image
FROM oci.badsysadm.local:80/deb/dev/dpkg-cvecheck:${CVECHECK_VERSION} AS cve_image

FROM 127.0.0.1:12670/get/dep:latest AS build
ARG VERSION

WORKDIR /src
RUN mkdir -p /target
COPY debian ./debian/
COPY --from=cve_image /deb/ /tmp/dpkg-cvecheck/
RUN apt-get -qq update && \
    apt-get -y -qq install /tmp/dpkg-cvecheck/dpkg-cvecheck_*.deb

RUN dh_prep
COPY --from=bin_image /target/ /src/debian/tmp/
RUN dpkg-vexgen
RUN dh_testdir
RUN dh_install
RUN dh_installdebconf
RUN dh_installdeb
RUN dh_installdirs
RUN dh_installlogcheck
RUN dh_installlogrotate
RUN dh_installmodules
RUN dh_installpam
RUN dh_installsystemd
RUN dh_installsystemduser
RUN dh_installsysusers
RUN dh_installtmpfiles
RUN dh_installudev
RUN dh_link
RUN dh_strip
RUN dh_fixperms
RUN dh_missing
RUN dh_strip_nondeterminism
RUN dh_makeshlibs
RUN dh_shlibdeps
RUN dh_perl
RUN dh_ucf
RUN dh_md5sums
RUN dh_gencontrol
RUN dh_builddeb --destdir=/target -- -Zxz -z9

FROM scratch
COPY --from=build /target/ /deb
COPY --from=build /src/debian/changelog /deb/changelog
