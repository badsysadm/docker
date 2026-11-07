ARG VERSION=3.9.0
FROM oci.badsysadm.local:80/dep/www/radicale:${VERSION} AS build
ARG VERSION

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
