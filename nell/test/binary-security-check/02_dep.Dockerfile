ARG VERSION=1.3.1
ARG RUST_VERSION=1.89.0

FROM oci.badsysadm.local:80/src/test/binary-security-check:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

ARG RUST_VERSION

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

ENV CARGO_HOME=/opt/cargo RUSTUP_HOME=/opt/rustup
ENV PATH=/opt/cargo/bin:${PATH}

RUN curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path \
    --profile minimal --default-toolchain "${RUST_VERSION}"

COPY --from=src_image /src/ /src/

WORKDIR /src/binary-security-check
RUN mkdir -p .cargo && \
    cargo vendor --locked /src/binary-security-check/vendor > .cargo/config.toml
