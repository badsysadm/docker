FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.25

RUN mkdir -p /src/which && \
    wget -qO- "https://ftp.gnu.org/gnu/which/which-${VERSION}.tar.gz" \
    | tar -xzf - -C /src/which --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
