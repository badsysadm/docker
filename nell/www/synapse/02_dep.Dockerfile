ARG VERSION=1.164.2
ARG PYTHON_VERSION=3.14.7
ARG RUST_VERSION=1.89.0

FROM oci.badsysadm.local:80/src/www/synapse:${VERSION} AS src_image
FROM 127.0.0.1:12670/pkg/dev/python3.14:${PYTHON_VERSION} AS python_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

ARG RUST_VERSION

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=python_image /usr/bin/python3.14 /usr/bin/python3.14
COPY --from=python_image /usr/lib/python3.14 /usr/lib/python3.14
COPY --from=python_image /usr/include/python3.14 /usr/include/python3.14

ENV CARGO_HOME=/opt/cargo RUSTUP_HOME=/opt/rustup
ENV PATH=/opt/cargo/bin:${PATH}

RUN curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path \
    --profile minimal --default-toolchain "${RUST_VERSION}"

RUN curl -fsSL https://bootstrap.pypa.io/get-pip.py | /usr/bin/python3.14

COPY --from=src_image /src/ /src/
WORKDIR /src/synapse
RUN mkdir -p .cargo \
    && cargo vendor --locked /src/synapse/vendor > .cargo/config.toml

ENV CARGO_NET_OFFLINE=true
RUN /usr/bin/python3.14 -m pip wheel --no-cache-dir \
    --wheel-dir /src/wheels ".[postgres]"
