FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.3.2

RUN git clone -q --single-branch --branch "${VERSION}" --depth 1 \
    https://gitlab.com/OldManProgrammer/unix-tree.git /src/tree

FROM scratch
COPY --from=build /src/ /src/
