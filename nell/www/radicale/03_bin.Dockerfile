ARG VERSION=3.9.0
ARG PYTHON_VERSION=3.14.7

FROM 127.0.0.1:12670/pkg/dev/python3.14:${PYTHON_VERSION} AS python_image
FROM oci.badsysadm.local:80/dep/www/radicale:${VERSION} AS build
ARG VERSION

COPY --from=python_image /usr/bin/python3.14 /src/target/usr/bin/python3.14
COPY --from=python_image /usr/lib/python3.14 /src/target/usr/lib/python3.14

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
    > /src/target/usr/bin/radicale \
    && chmod 0755 /src/target/usr/bin/radicale

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="radicale"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="CalDAV and CardDAV server"
COPY --from=build /src/target/ /target/
