FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG BUILDBOT_VERSION=v4.3.0

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    ca-certificates \
    build-essential git python3 python3-venv python3-setuptools python3-wheel python3-build curl \
    zlib1g-dev libbz2-dev libssl-dev libzstd-dev

COPY --from=127.0.0.1:12670/pkg/dev/python3.14:3.14.7 /usr/bin/python3 /usr/bin/python3.14 /usr/bin/
COPY --from=127.0.0.1:12670/pkg/dev/python3.14:3.14.7 /usr/lib/python3.14 /usr/lib/python3.14

RUN curl -sS https://bootstrap.pypa.io/get-pip.py | /usr/bin/python3.14

RUN mkdir -p /src/target/wheels /src/target/usr/lib/python3.14/site-packages /src/target/usr/lib64

RUN git clone --single-branch --branch ${BUILDBOT_VERSION} --depth 1 https://github.com/buildbot/buildbot.git /src/buildbot

#RUN /usr/bin/python3.14 -m pip wheel --wheel-dir /src/wheels /src/buildbot/master /src/buildbot/www/base
RUN /usr/bin/python3.14 -m pip wheel --wheel-dir /src/wheels "/src/buildbot/master[bundle]"

RUN for f in /src/wheels/*.whl; do /usr/bin/python3.14 -m zipfile -e "$f" /src/target/usr/lib/python3.14/site-packages/; done

RUN cp -rfv /usr/lib/x86_64-linux-gnu/libz.so* /src/target/usr/lib64/ && \
    cp -rfv /usr/lib/x86_64-linux-gnu/libbz2.so* /src/target/usr/lib64/ && \
    cp -rfv /usr/lib/x86_64-linux-gnu/libgcc_s* /src/target/usr/lib64/ && \
    cp -rfv /usr/lib/x86_64-linux-gnu/libssl.so* /src/target/usr/lib64/ && \
    cp -rfv /usr/lib/x86_64-linux-gnu/libcrypto.so* /src/target/usr/lib64/ && \
    cp -rfv /usr/lib/x86_64-linux-gnu/libpthread.so* /src/target/usr/lib64/ && \
    cp -rfv /usr/lib/x86_64-linux-gnu/libsqlite3.so.* /src/target/usr/lib64/ && \
    cp -rfv /usr/lib/x86_64-linux-gnu/libzstd.so* /src/target/usr/lib64/

WORKDIR /src/target/usr/bin
RUN ln -s coreutils tail
WORKDIR /src/target
RUN echo 'ID=_any' > usr/lib/os-release

FROM scratch AS bundle
LABEL org.opencontainers.image.title="buildbot"
LABEL org.opencontainers.image.version="v4.3.0"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Buildbot continuous integration system"
COPY --from=build /src/target/ /
COPY --from=127.0.0.1:12670/pkg/dev/python3.14:3.14.7 /usr/bin/python3 /usr/bin/python3.14 /usr/bin/
COPY --from=127.0.0.1:12670/pkg/dev/python3.14:3.14.7 /usr/lib/python3.14 /usr/lib/python3.14
COPY --from=127.0.0.1:12670/pkg/libs/glibc:2.44 /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
COPY --from=127.0.0.1:12670/pkg/libs/glibc:2.44 /lib64/libc.so.6 /lib64/libm.so.6 /lib64/
COPY --from=127.0.0.1:12670/pkg/utils/coreutils:9.5 /usr/bin/coreutils /usr/bin/
COPY --from=127.0.0.1:12670/pkg/utils/git:2.56.0 /usr/bin/git /usr/bin/
COPY buildbot.service /usr/lib/systemd/system/

CMD ['/usr/bin/python3.14', '-c', '"from buildbot.scripts import runner; runner.run()" start --nodaemon']
