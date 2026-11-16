ARG VERSION=0.3.2

FROM oci.badsysadm.local:80/dep/test/binsider:${VERSION} AS build
ARG VERSION

ENV CARGO_HOME=/opt/cargo RUSTUP_HOME=/opt/rustup
ENV PATH=/opt/cargo/bin:${PATH}
ENV CARGO_NET_OFFLINE=true

WORKDIR /src/binsider

RUN RUSTFLAGS="-C link-arg=-static-libgcc" \
    cargo build --offline --locked --release --bin binsider

RUN install -D -m 0755 target/release/binsider /src/target/usr/bin/binsider

FROM scratch AS bundle
ARG VERSION
LABEL org.opencontainers.image.title="binsider"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors="Egor Artemov <me@badsysadm.com>"
LABEL org.opencontainers.image.description="Terminal ELF static and dynamic analysis tool"
COPY --from=build /src/target/ /target/
