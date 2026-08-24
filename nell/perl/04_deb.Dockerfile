ARG VERSION=5.44.0

FROM 127.0.0.1:12670/bin/perl/perl:${VERSION} AS bin_image

FROM 127.0.0.1:12670/get/dep:latest AS build
ARG VERSION
ARG EMAIL="me@badsysadm.com"
ARG DEBFULLNAME="Egor Artemov"
ARG SOURCE_DATE_EPOCH=728438400

WORKDIR /src
RUN mkdir -p /target
COPY debian ./debian/
RUN dh_prep
COPY --from=bin_image /target/* /src/debian/tmp/
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
RUN dch --create --empty --package $(sed -ne 's/^Source: //p' debian/control | head -n1) --newversion ${VERSION}-1 -D stable "Automated pipeline build."
RUN dh_gencontrol
RUN dh_builddeb --destdir=/target -- -Zxz -z9

FROM scratch
COPY --from=build /target/ /deb
COPY --from=build /src/debian/changelog /deb/changelog
