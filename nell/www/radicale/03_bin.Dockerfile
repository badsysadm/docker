ARG VERSION=3.9.0
ARG PYTHON_VERSION=3.14.7
ARG GLIBC_VERSION=2.44
ARG OPENSSL_VERSION=3.6.5
ARG ZLIB_VERSION=1.3.1

FROM 127.0.0.1:12670/pkg/dev/python3.14:${PYTHON_VERSION} AS python_image
FROM 127.0.0.1:12670/pkg/libs/glibc:${GLIBC_VERSION} AS glibc_image
FROM oci.badsysadm.local:80/bin/security/openssl:${OPENSSL_VERSION} AS openssl_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM oci.badsysadm.local:80/dep/www/radicale:${VERSION} AS build
ARG VERSION

COPY --from=python_image /usr/bin/python3.14 /src/target/usr/bin/python3.14
COPY --from=python_image /usr/lib/python3.14 /src/target/usr/lib/python3.14

COPY --from=glibc_image /lib64/ld-linux-x86-64.so.2 /src/target/lib64/ld-linux-x86-64.so.2
COPY --from=glibc_image /lib64/libc.so.6 /lib64/libm.so.6 /src/target/lib64/
COPY --from=zlib_image /target/usr/lib/x86_64-linux-gnu/libz.so* /src/target/usr/lib64/
COPY --from=openssl_image /target/usr/lib64/libssl.so* /src/target/usr/lib64/
COPY --from=openssl_image /target/usr/lib64/libcrypto.so* /src/target/usr/lib64/

RUN /usr/bin/python3.14 -m pip install --no-index \
    --find-links=/src/wheels --no-compile \
    --target=/src/target/usr/lib/python3.14/site-packages \
    "Radicale[ldap]==${VERSION}"

RUN printf '%s\n' \
    '#!/usr/bin/python3.14' \
    'import sys' \
    'sys.path.insert(0, "/usr/lib/python3.14/site-packages")' \
    'from radicale.__main__ import run' \
    'run()' \
    > /src/target/usr/bin/radicale

RUN chmod 0755 /src/target/usr/bin/radicale

RUN find /src/target/usr/lib/python3.14 \
    -type d -name __pycache__ -prune -exec rm -rf {} +

RUN find /src/target/usr/lib/python3.14 -type f -name '*.pyc' -delete

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="radicale"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="CalDAV and CardDAV server"
COPY --from=build /src/target/ /target/
