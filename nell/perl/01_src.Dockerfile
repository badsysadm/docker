FROM 127.0.0.1:12670/get/source:latest AS build
ARG VERSION=5.44.0

RUN git clone --single-branch --branch "v${VERSION}" --depth 1 https://github.com/Perl/perl5.git /src/perl5

FROM scratch
COPY --from=build /src/perl5/ /src
