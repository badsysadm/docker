ARG VERSION=2.26.13

FROM oci.badsysadm.local:80/dep/dev/devscripts:${VERSION} AS build
ARG VERSION

WORKDIR /src/devscripts

# Upstream scripts/Makefile substitutes the release version into scripts.
RUN sed -i "s/###VERSION###/${VERSION}/g" scripts/*.pl scripts/*.sh

# Each Perl command is packaged individually. Dynamically loaded Dpkg
# vendor modules need explicit inclusion, as with mk-build-deps.
RUN mkdir -p /src/target/usr/bin /src/target/usr/share/devscripts && \
    for file in scripts/*.pl; do \
        name="${file##*/}"; \
        name="${name%.pl}"; \
        output="/src/target/usr/bin/${name}"; \
        TZ=UTC PERL_HASH_SEED=0 PERL_PERTURB_KEYS=0 \
        faketime -f '2020-01-01 00:00:00' \
        pp -B -I lib \
           -M Dpkg::Changelog::Parse \
           -M Dpkg::Vendor::Default \
           -M Dpkg::Vendor::Debian \
           -o "${output}" "${file}" || exit 1; \
    done

# Keep all shell commands as scripts. debbisect's helpers have a separate
# runtime path, matching the upstream installation layout.
RUN mkdir -p /src/target/usr/share/devscripts/scripts && \
    for file in scripts/*.sh; do \
        name="${file##*/}"; \
        name="${name%.sh}"; \
        output="/src/target/usr/bin/${name}"; \
        case "${name}" in \
            run_bisect|run_bisect_qemu) \
                output="/src/target/usr/share/devscripts/scripts/${name}";; \
        esac; \
        install -m 755 "${file}" "${output}" || exit 1; \
    done

# Python entrypoints remain Python; setup.py is an installation helper.
RUN for name in deb-janitor debbisect debdiff-apply debootsnap \
                reproducible-check sadt suspicious-source wrap-and-sort; do \
        install -m 755 "scripts/${name}" \
            "/src/target/usr/bin/${name}" || exit 1; \
    done && \
    mkdir -p /src/target/usr/lib/python3/dist-packages/devscripts && \
    install -m 644 scripts/devscripts/*.py \
        /src/target/usr/lib/python3/dist-packages/devscripts/ && \
    printf "version = '%s'\n" "${VERSION}" \
        > /src/target/usr/lib/python3/dist-packages/devscripts/__init__.py

# Runtime files used by the original devscripts commands.
RUN mkdir -p /src/target/usr/share/devscripts/templates && \
    cp -a templates/. /src/target/usr/share/devscripts/templates/ && \
    sed "s/###VERSION###/${VERSION}/g" conf.default.in \
        > /src/target/usr/share/devscripts/conf.default && \
    chmod 755 /src/target/usr/bin/*

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="devscripts"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Debian devscripts: PAR-packed Perl tools and original shell/Python programs"
COPY --from=build /src/target/ /target/
