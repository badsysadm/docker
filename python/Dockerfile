FROM 127.0.0.1:12670/distro/debian:trixie AS build
ARG PYTHON_VERSION=3.14.7

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    ca-certificates \
    build-essential git pkg-config wget zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev libssl-dev libffi-dev liblzma-dev libgdbm-dev tk-dev

RUN mkdir -p /src/target
RUN git clone --single-branch --branch v${PYTHON_VERSION} --depth 1 https://github.com/python/cpython.git /src/cpython
WORKDIR /src/cpython/build

RUN ../configure \
    --prefix=/usr \
    --enable-optimizations \
    --disable-test-modules \
    --without-ensurepip \
    LDFLAGS="-static-libgcc"

RUN make -j$(nproc)
RUN make install DESTDIR=/src/target

RUN rm -rf /src/target/usr/lib/python3*/idlelib \
           /src/target/usr/lib/python3*/turtledemo \
           /src/target/usr/lib/python3*/pydoc_data \
           /src/target/usr/lib/python3*/tkinter \
           /src/target/usr/lib/python3*/turtle.py \
           /src/target/usr/lib/python3*/config-* \
           /src/target/usr/lib/lib-dynload/_tkinter.*.so 

RUN find /src/target/usr/lib/python3*/ -type d -name "__pycache__" -exec rm -rf {} + && \
    find /src/target/usr/lib/python3*/ -name "*.pyc" -delete

RUN rm -rf /src/target/usr/bin/idle3* \
           /src/target/usr/bin/pydoc* \
           /src/target/usr/bin/python3*-config

RUN rm -rf /src/target/usr/share/man

FROM scratch AS bundle
LABEL org.opencontainers.image.title="python"
LABEL org.opencontainers.image.version="3.14.7"
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Python programming language compiled from source with disabled docs and tests"
COPY --from=build /src/target/ /
