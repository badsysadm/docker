ARG VERSION=2.3.3

FROM oci.badsysadm.local:80/dep/dev/equivs:${VERSION} AS build
ARG VERSION

WORKDIR /src/equivs

# equivs-build is Perl; equivs-control is a shell script.
RUN mkdir -p /src/target/usr/bin /src/target/usr/share/equivs && \
    TZ=UTC PERL_HASH_SEED=0 PERL_PERTURB_KEYS=0 \
    faketime -f '2020-01-01 00:00:00' \
    pp -B \
       -M Dpkg::Vendor::Default \
       -M Dpkg::Vendor::Debian \
       -o /src/target/usr/bin/equivs-build \
       usr/bin/equivs-build && \
    install -m 755 usr/bin/equivs-control \
        /src/target/usr/bin/equivs-control

# These templates are runtime inputs, not documentation.
RUN cp -a usr/share/equivs/. /src/target/usr/share/equivs/

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="equivs"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="equivs-build (PAR::Packer) and equivs-control (shell)"
COPY --from=build /src/target/ /target/
