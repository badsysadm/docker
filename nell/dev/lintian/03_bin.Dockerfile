ARG VERSION=2.142.0

FROM oci.badsysadm.local:80/dep/dev/lintian:${VERSION} AS build
ARG VERSION

WORKDIR /src/lintian

COPY debian/patches /src/patches/
RUN git apply /src/patches/_par-runtime.patch

# Populate the upstream version placeholder from the build argument.
RUN VERSION="${VERSION}" perl -pi -e 's/^my \$LINTIAN_VERSION;/my \$LINTIAN_VERSION = "$ENV{VERSION}";/' bin/lintian

# MLDBM requires BerkeleyDB/Btree.pm by filename, but BerkeleyDB defines
# BerkeleyDB::Btree in BerkeleyDB.pm. Supply a loader for PAR.
RUN mkdir -p /src/vendor/perl/BerkeleyDB && \
    printf 'package BerkeleyDB::Btree; require BerkeleyDB; 1;\\n' \
        > /src/vendor/perl/BerkeleyDB/Btree.pm

# Some checks are loaded dynamically by name: enumerate all Lintian modules
# rather than relying solely on PAR's static dependency discovery.
RUN mkdir -p /src/target/usr/bin && \
    set --; \
    for file in $(find lib/Lintian -type f -name '*.pm' | LC_ALL=C sort); do \
        module="${file#lib/}"; \
        module="${module%.pm}"; \
        module="$(printf '%s' "${module}" | sed 's@/@::@g')"; \
        set -- "$@" -M "${module}"; \
    done; \
    for soname in \
        libyaml-0.so.2 libxml2.so.2 libmarkdown.so.2 libz.so.1 \
        libssl.so.3 libcrypto.so.3 libmagic.so.1 libbz2.so.1.0 \
        libdb-5.3.so libapt-pkg.so.7.0 libgcc_s.so.1; do \
        library="$(ldconfig -p | awk -v name="$soname" '$1 == name { print $NF; exit }')"; \
        if [ -z "$library" ] || [ ! -f "$library" ]; then \
            echo "Missing shared library: $soname" >&2; \
            exit 1; \
        fi; \
        set -- "$@" -l "$library"; \
    done; \
    TZ=UTC PERL_HASH_SEED=0 PERL_PERTURB_KEYS=0 \
    faketime -f '2020-01-01 00:00:00' \
    env PERL5LIB=/src/vendor/perl pp -B -I /src/vendor/perl -I lib \
        -a "$(perl -MConfig -e 'print "$Config{privlib}/unicore/Name.pl"');lib/unicore/Name.pl" \
        -M namespace::clean -M IPC::Run3 -M Debian::DistroInfo -M _charnames \
        -M MLDBM::Serializer::Storable -M BerkeleyDB::Btree \
        -M Data::DPath -M Data::DPath::Attrs -M Data::DPath::Context \
        -M Data::DPath::Filters -M Data::DPath::Path \
        -M Data::DPath::Point -M Data::DPath::Step "$@" -o /src/target/usr/bin/lintian bin/lintian

# Lintian enumerates checks and reads tags, profiles and vendor databases at
# runtime. These are essential inputs, not documentation.
RUN mkdir -p /src/target/usr/share/lintian && \
    cp -a data tags profiles vendors private commands \
        /src/target/usr/share/lintian/

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="lintian"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Lintian bundled using PAR::Packer"
COPY --from=build /src/target/ /target/
