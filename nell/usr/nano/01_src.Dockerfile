FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=9.2
ARG NANO_SYNTAX_VERSION=2026.11.01

RUN mkdir -p /src/nano && \
    wget -qO- "https://ftp.gnu.org/gnu/nano/nano-${VERSION}.tar.xz" \
    | tar -xJf - -C /src/nano --strip-components=1

RUN git clone -q --single-branch --branch "${NANO_SYNTAX_VERSION}" --depth 1 \
    https://github.com/galenguyer/nano-syntax-highlighting.git /src/nano-syntax-highlighting

FROM scratch
COPY --from=build /src/ /src/
