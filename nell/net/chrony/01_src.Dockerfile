FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=4.9

RUN mkdir -p /src/chrony && \
    wget -qO- "https://chrony-project.org/releases/chrony-${VERSION}.tar.gz" | \
    tar -xzf - -C /src/chrony --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
