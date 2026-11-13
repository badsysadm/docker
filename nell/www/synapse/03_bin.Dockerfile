ARG VERSION=1.164.2
ARG PYTHON_VERSION=3.14.7
ARG GLIBC_VERSION=2.44
ARG OPENSSL_VERSION=3.6.5
ARG ZLIB_VERSION=1.3.1

FROM oci.badsysadm.local:80/pkg/dev/python3.14:${PYTHON_VERSION} AS python_image
FROM oci.badsysadm.local:80/bin/system/glibc:${GLIBC_VERSION} AS glibc_image
FROM oci.badsysadm.local:80/bin/security/openssl:${OPENSSL_VERSION} AS openssl_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM oci.badsysadm.local:80/dep/www/synapse:${VERSION} AS build
ARG VERSION

COPY --from=python_image /usr/bin/python3.14 /src/target/usr/bin/python3.14
COPY --from=python_image /usr/lib/python3.14 /src/target/usr/lib/python3.14

COPY --from=glibc_image /lib64/ld-linux-x86-64.so.2 /src/target/lib64/ld-linux-x86-64.so.2
COPY --from=glibc_image /lib64/libc.so.6 /lib64/libm.so.6 /lib64/libpthread.so.0 /lib64/librt.so.1 /lib64/libdl.so.2 /src/target/lib64/
COPY --from=zlib_image /target/usr/lib/x86_64-linux-gnu/libz.so* /src/target/usr/lib64/
COPY --from=openssl_image /target/usr/lib64/libssl.so* /src/target/usr/lib64/
COPY --from=openssl_image /target/usr/lib64/libcrypto.so* /src/target/usr/lib64/

RUN cp -a /usr/lib/x86_64-linux-gnu/libffi.so.8* /src/target/usr/lib64/
RUN cp -a /lib/x86_64-linux-gnu/libgcc_s.so.1 /src/target/usr/lib64/
RUN cp -a /usr/lib/x86_64-linux-gnu/libpq.so.5* /src/target/usr/lib64/
RUN cp -a /usr/lib/x86_64-linux-gnu/libsqlite3.so.0* /src/target/usr/lib64/

RUN /usr/bin/python3.14 -m pip install --no-index \
    --find-links=/src/wheels --no-compile \
    --target=/src/target/usr/lib/python3.14/site-packages \
    "matrix-synapse[postgres]==${VERSION}"

RUN for entry in \
    'synapse_homeserver synapse.app.homeserver' \
    'synapse_worker synapse.app.generic_worker' \
    'synctl synapse._scripts.synctl' \
    'generate_config synapse._scripts.generate_config' \
    'register_new_matrix_user synapse._scripts.register_new_matrix_user'; do \
    set -- ${entry}; \
    printf '#!/usr/bin/python3.14\nimport sys\nsys.path.insert(0, "/usr/lib/python3.14/site-packages")\nfrom %s import main\nmain()\n' "$2" \
        > "/src/target/usr/bin/$1"; \
    chmod 0755 "/src/target/usr/bin/$1"; \
    done

RUN find /src/target/usr/lib/python3.14 \
    -type d -name __pycache__ -prune -exec rm -rf {} +
RUN find /src/target/usr/lib/python3.14 -type f -name '*.pyc' -delete

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="synapse"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Matrix Synapse homeserver"
COPY --from=build /src/target/ /target/
