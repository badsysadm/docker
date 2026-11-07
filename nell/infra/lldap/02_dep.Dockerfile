ARG VERSION=0.6.3
ARG RUST_VERSION=1.89.0
ARG WASM_PACK_VERSION=0.13.1

FROM oci.badsysadm.local:80/src/infra/lldap:${VERSION} AS src_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

ARG RUST_VERSION
ARG WASM_PACK_VERSION

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

ENV CARGO_HOME=/opt/cargo RUSTUP_HOME=/opt/rustup
ENV PATH=/opt/cargo/bin:${PATH}

RUN curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path \
    --profile minimal --default-toolchain "${RUST_VERSION}"
RUN rustup target add wasm32-unknown-unknown
RUN cargo install wasm-pack --version "${WASM_PACK_VERSION}" --locked

COPY --from=src_image /src/ /src/

WORKDIR /src/lldap
RUN WASM_BINDGEN_VERSION=$(awk '/^name = "wasm-bindgen"$/ {getline; gsub(/"/, "", $3); print $3; exit}' Cargo.lock) \
    && cargo install wasm-bindgen-cli --version "${WASM_BINDGEN_VERSION}" --locked

RUN mkdir -p .cargo \
    && cargo vendor --locked /src/lldap/vendor > .cargo/config.toml

RUN while IFS= read -r url; do \
        curl -fsSL "${url}" -o "app/static/$(basename "${url}")" || exit 1; \
    done < app/static/libraries.txt \
    && while IFS= read -r url; do \
        curl -fsSL "${url}" -o "app/static/fonts/$(basename "${url}")" || exit 1; \
    done < app/static/fonts/fonts.txt
