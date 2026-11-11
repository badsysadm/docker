ARG VERSION=2.142.0

FROM oci.badsysadm.local:80/dep/dev/lintian:${VERSION} AS build
ARG VERSION

WORKDIR /src/lintian

COPY debian/patches /src/patches/
RUN git apply /src/patches/_par-runtime.patch

# Populate the upstream version placeholder from the build argument.
RUN sed -i "s/my \\$LINTIAN_VERSION;/my \\$LINTIAN_VERSION = '${VERSION}';/" bin/lintian

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
    pp -B -I lib -M namespace::clean -M IPC::Run3 -M Debian::DistroInfo "$@" -o /src/target/usr/bin/lintian bin/lintian

# Lintian enumerates checks and reads tags, profiles and vendor databases at
# runtime. These are essential inputs, not documentation.
RUN mkdir -p /src/target/usr/share/lintian && \
    cp -a lib data tags profiles vendors private commands \
        /src/target/usr/share/lintian/

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="lintian"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Lintian bundled using PAR::Packer"
COPY --from=build /src/target/ /target/
