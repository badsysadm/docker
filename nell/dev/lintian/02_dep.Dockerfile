ARG VERSION=2.142.0

FROM oci.badsysadm.local:80/src/dev/lintian:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"' debian/control

COPY --from=src_image /src/ /src/

# Vendor the upstream Perl module; the Trixie package is older than Lintian requires.
RUN mkdir -p /src/vendor/perl/Debian && \
    cp /src/distro-info/perl/Debian/DistroInfo.pm /src/vendor/perl/Debian/DistroInfo.pm && \
    PERL5LIB=/src/vendor/perl perl -MDebian::DistroInfo -e \
      'die "get_all_series unavailable\\n" unless Debian::DistroInfo->can("get_all_series")'
