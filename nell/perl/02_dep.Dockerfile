ARG VERSION=5.44.0

FROM 127.0.0.1:12670/src/perl/perl:${VERSION} AS src_image
FROM 127.0.0.1:12670/get/dep:latest AS build

COPY debian ./debian/
RUN mk-build-deps --install --remove --tool "apt-get -y -qq"

COPY --from=src_image /src /src/perl/
