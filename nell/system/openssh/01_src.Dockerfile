FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=10.5p1

RUN MAJOR_MINOR=$(echo ${VERSION} | cut -d'p' -f1 | tr '.' '_') && \
    PATCH=$(echo ${VERSION} | grep -o 'p[0-9]*' | tr 'p' 'P') && \
    BRANCH="V_${MAJOR_MINOR}_${PATCH}" && \
    git clone -q --single-branch --branch "${BRANCH}" --depth 1 https://github.com/openssh/openssh-portable.git /src/openssh

FROM scratch
COPY --from=build /src/ /src
