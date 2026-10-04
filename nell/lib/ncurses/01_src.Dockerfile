FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=6.6

RUN mkdir -p /src/ncurses /src/target && \
    wget -qO- https://invisible-island.net/archives/ncurses/ncurses-${VERSION}.tar.gz | tar -xzf - -C /src/ncurses --strip-components=1

FROM scratch
COPY --from=build /src/ncurses/ /src
