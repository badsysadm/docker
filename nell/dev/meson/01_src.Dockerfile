FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=1.12.1

RUN mkdir -p /src/meson && \
    wget -qO- "https://github.com/mesonbuild/meson/archive/refs/tags/${VERSION}.tar.gz" | \
    tar -xzf - -C /src/meson --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
