FROM alpine:latest AS build
RUN apk update && apk add git wget
WORKDIR /src
RUN wget -qO- https://download.limesurvey.org/latest-master/limesurvey6.3.8+231204.zip | busybox unzip -
RUN mkdir -p /var/lib/limesurvey/docker-entrypoint.d

FROM nginx/unit:1.29.1-php8.1 AS base
COPY --from=build /src/limesurvey /var/www/limesurvey
RUN chown unit:unit -R /var/www/limesurvey
COPY --chmod=555 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh 
COPY --from=build --chmod=750 --chown=unit:unit /var/lib/limesurvey/* /var/lib/limesurvey/
