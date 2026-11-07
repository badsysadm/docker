FROM oci.badsysadm.local:80/get/source:latest AS build
ARG VERSION=3.14

RUN git clone -q --single-branch --branch "v${VERSION}" --depth 1 \
    https://github.com/rss2email/rss2email.git /src/rss2email

FROM scratch
COPY --from=build /src/ /src/
