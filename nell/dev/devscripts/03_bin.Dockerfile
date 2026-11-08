ARG VERSION=2.26.13

FROM oci.badsysadm.local:80/dep/dev/devscripts:${VERSION} AS build
ARG VERSION

WORKDIR /src/devscripts

# Substitute the release version just as the upstream scripts/Makefile does.
RUN sed -i "s/###VERSION###/${VERSION}/g" \
    scripts/mk-build-deps.pl \
    scripts/debuild.pl \
    scripts/dpkg-depcheck.pl \
    scripts/debdiff.pl \
    scripts/debc.pl \
    scripts/hardening-check.pl \
    scripts/dscverify.pl \
    scripts/debchange.pl

# Perl programs are packaged individually, including local Devscripts modules.
# Dpkg::Vendor and Changelog::Parse are also loaded dynamically.
RUN mkdir -p /src/target/usr/bin && \
    for name in mk-build-deps debuild dpkg-depcheck debdiff debc hardening-check dscverify; do \
        TZ=UTC PERL_HASH_SEED=0 PERL_PERTURB_KEYS=0 \
        faketime -f '2020-01-01 00:00:00' \
        pp -B -I lib \
           -M Dpkg::Changelog::Parse \
           -M Dpkg::Vendor::Default \
           -M Dpkg::Vendor::Debian \
           -o "/src/target/usr/bin/${name}" \
           "scripts/${name}.pl" || exit 1; \
    done && \
    TZ=UTC PERL_HASH_SEED=0 PERL_PERTURB_KEYS=0 \
    faketime -f '2020-01-01 00:00:00' \
    pp -B -I lib \
       -M Dpkg::Changelog::Parse \
       -M Dpkg::Vendor::Default \
       -M Dpkg::Vendor::Debian \
       -o /src/target/usr/bin/dch \
       scripts/debchange.pl

# Keep shell utilities as shell scripts, without packaging them with pp.
RUN for name in debclean dpkg-genbuilddeps debsign; do \
        sed "s/###VERSION###/${VERSION}/g" "scripts/${name}.sh" \
            > "/src/target/usr/bin/${name}" || exit 1; \
    done && \
    chmod 755 /src/target/usr/bin/*

# Python scripts remain Python. Keep their local support module available.
RUN install -m 755 scripts/suspicious-source /src/target/usr/bin/suspicious-source && \
    mkdir -p /src/target/usr/lib/python3/dist-packages/devscripts && \
    install -m 644 scripts/devscripts/logger.py \
        /src/target/usr/lib/python3/dist-packages/devscripts/logger.py

# The removed utility is retained from the last Debian stable source version.
RUN install -m 755 legacy/scripts/deb-check-file-conflicts \
    /src/target/usr/bin/deb-check-file-conflicts

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="devscripts"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Selected Debian devscripts: PAR-packed Perl and original shell/Python programs"
COPY --from=build /src/target/ /target/
