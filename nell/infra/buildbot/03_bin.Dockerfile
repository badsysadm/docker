ARG VERSION=4.3.0
ARG PYTHON_VERSION=3.14.7
ARG GLIBC_VERSION=2.44
ARG OPENSSL_VERSION=3.6.5
ARG ZLIB_VERSION=1.3.1
ARG GIT_VERSION=2.56.0

FROM 127.0.0.1:12670/pkg/dev/python3.14:${PYTHON_VERSION} AS python_image
FROM oci.badsysadm.local:80/bin/system/glibc:${GLIBC_VERSION} AS glibc_image
FROM oci.badsysadm.local:80/bin/security/openssl:${OPENSSL_VERSION} AS openssl_image
FROM oci.badsysadm.local:80/bin/lib/zlib:${ZLIB_VERSION} AS zlib_image
FROM 127.0.0.1:12670/pkg/utils/git:${GIT_VERSION} AS git_image
FROM oci.badsysadm.local:80/dep/infra/buildbot:${VERSION} AS build
ARG VERSION

COPY --from=python_image /usr/bin/python3 /usr/bin/python3.14 /src/target/usr/bin/
COPY --from=python_image /usr/lib/python3.14 /src/target/usr/lib/python3.14

COPY --from=glibc_image /target/lib64/ld-linux-x86-64.so.2 /src/target/lib64/ld-linux-x86-64.so.2
COPY --from=glibc_image /target/lib64/libc.so.6 /target/lib64/libm.so.6 /target/lib64/libpthread.so.0 /src/target/lib64/
COPY --from=openssl_image /target/usr/lib64/libssl.so* /src/target/usr/lib64/
COPY --from=openssl_image /target/usr/lib64/libcrypto.so* /src/target/usr/lib64/
COPY --from=zlib_image /target/usr/lib/x86_64-linux-gnu/libz.so* /src/target/usr/lib64/

COPY --from=git_image /usr/bin/git /src/target/usr/bin/git
COPY debian/buildbot.service /src/target/usr/lib/systemd/system/buildbot.service

RUN cp -a /usr/lib/x86_64-linux-gnu/libbz2.so* /src/target/usr/lib64/ \
    && cp -a /lib/x86_64-linux-gnu/libgcc_s.so.1 /src/target/usr/lib64/ \
    && cp -a /usr/lib/x86_64-linux-gnu/libsqlite3.so.0* /src/target/usr/lib64/ \
    && cp -a /usr/lib/x86_64-linux-gnu/libzstd.so* /src/target/usr/lib64/

RUN /usr/bin/python3.14 -m pip install --no-index \
    --find-links=/src/wheels --no-compile \
    --target=/src/target/usr/lib/python3.14/site-packages \
    "buildbot[bundle]==${VERSION}"

RUN printf '%s\n' \
    '#!/usr/bin/python3.14' \
    'import sys' \
    'sys.path.insert(0, "/usr/lib/python3.14/site-packages")' \
    'from buildbot.scripts import runner' \
    'runner.run()' \
    > /src/target/usr/bin/buildbot

RUN chmod 0755 /src/target/usr/bin/buildbot

RUN printf '%s\n' \
    '#!/usr/bin/python3.14' \
    'import sys' \
    'sys.path.insert(0, "/usr/lib/python3.14/site-packages")' \
    'from buildbot_worker.scripts.runner import run' \
    'run()' \
    > /src/target/usr/bin/buildbot-worker

RUN chmod 0755 /src/target/usr/bin/buildbot-worker

RUN find /src/target/usr/lib/python3.14 \
    -type d -name __pycache__ -prune -exec rm -rf {} +
RUN find /src/target/usr/lib/python3.14 -type f -name '*.pyc' -delete

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="buildbot"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Buildbot continuous integration system"
COPY --from=build /src/target/ /target/
