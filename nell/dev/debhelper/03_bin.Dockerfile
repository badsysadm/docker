ARG VERSION=14.5

FROM oci.badsysadm.local:80/dep/dev/debhelper:${VERSION} AS build
ARG VERSION

WORKDIR /src/debhelper

# The upstream installation target does not need tests or manpage generation.
# It installs dh, dh_* and the templates and Perl modules they need.
RUN make version USE_NLS=no && \
    make install USE_NLS=no DESTDIR=/src/stage

# Include every bundled Debian::Debhelper module: some sequence and
# buildsystem implementations are loaded dynamically at runtime.
RUN mkdir -p /src/target/usr/bin && \
    set --; \
    for file in $(find lib/Debian/Debhelper -type f -name '*.pm' | LC_ALL=C sort); do \
        module="${file#lib/}"; \
        module="${module%.pm}"; \
        module="$(printf '%s' "${module}" | sed 's@/@::@g')"; \
        set -- "$@" -M "${module}"; \
    done; \
    for file in /src/stage/usr/bin/dh /src/stage/usr/bin/dh_*; do \
        [ -f "${file}" ] || continue; \
        name="${file##*/}"; \
        TZ=UTC PERL_HASH_SEED=0 PERL_PERTURB_KEYS=0 \
        faketime -f '2020-01-01 00:00:00' \
        pp -B -I lib "$@" -o "/src/target/usr/bin/${name}" "${file}" || exit 1; \
    done

# autoscripts are required at runtime and are not Perl modules.
RUN mkdir -p /src/target/usr/share/debhelper && \
    cp -a /src/stage/usr/share/debhelper/autoscripts \
        /src/target/usr/share/debhelper/

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="debhelper"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Debian dh and dh_* programs packaged with PAR::Packer"
COPY --from=build /src/target/ /target/
