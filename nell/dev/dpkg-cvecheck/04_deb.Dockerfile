ARG VERSION=0.1.0

FROM oci.badsysadm.local:80/src/dev/dpkg-cvecheck:${VERSION} AS src_image
FROM oci.badsysadm.local:80/bin/dev/dpkg-cvecheck:${VERSION} AS bin_image
FROM oci.badsysadm.local:80/get/dep:latest AS build
ARG VERSION
ARG EMAIL="me@badsysadm.com"
ARG DEBFULLNAME="Egor Artemov"
ARG SOURCE_DATE_EPOCH=728438400

WORKDIR /src
COPY --from=src_image /src/dpkg-cvecheck/debian/ ./debian/

RUN dh_prep
COPY --from=bin_image /target/ /src/debian/dpkg-cvecheck/

RUN dh_testdir && \
    dh_fixperms && \
    dh_installdeb && \
    dh_md5sums && \
    dch --create --empty --package dpkg-cvecheck \
        --newversion "${VERSION}-1" -D stable "Automated pipeline build." && \
    dh_gencontrol && \
    dh_builddeb --destdir=/target -- -Zxz -z9

FROM scratch
COPY --from=build /target/ /deb/
COPY --from=build /src/debian/changelog /deb/changelog
