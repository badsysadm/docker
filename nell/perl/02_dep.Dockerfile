ARG VERSION=5.44.0

FROM 127.0.0.1:12670/src/perl/perl:${VERSION} AS src_image

FROM 127.0.0.1:12670/get/dep:latest AS build

COPY debian ./debian/
RUN mk-build-deps --install --remove --tool "apt-get -y -qq"
#RUN apt-get update && apt-get install -y -qq --no-install-recommends \
#    build-essential perl

WORKDIR /src/perl
COPY --from=src_image /src ./
