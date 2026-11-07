FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=2.56.0

RUN mkdir -p /src/git && \
    wget -qO- \
        "https://www.kernel.org/pub/software/scm/git/git-${VERSION}.tar.xz" | \
    tar -xJf - -C /src/git --strip-components=1

FROM scratch
COPY --from=build /src/ /src/
