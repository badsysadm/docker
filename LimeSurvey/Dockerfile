FROM alpine:latest AS build
RUN apk update && apk add git wget
WORKDIR /src
RUN wget -qO- https://download.limesurvey.org/latest-master/limesurvey6.3.8+231204.zip | busybox unzip -
RUN mkdir -p /var/lib/limesurvey/docker-entrypoint.d

FROM nginx/unit:1.29.1-php8.1 AS base
RUN set -ex; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
                netcat-openbsd \
                libldap-common \
                libsasl2-modules \
        ; \
        \
        apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
        rm -rf /var/lib/apt/lists/*
RUN set -ex; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
                libldap2-dev \
                libfreetype6-dev \
                libjpeg-dev \
                libonig-dev \
                zlib1g-dev \
                libc-client-dev \
                libkrb5-dev \
                libpng-dev \
                libpq-dev \
                libzip-dev \
                libtidy-dev \
                libsodium-dev \
        ; \
        \
        debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
        docker-php-ext-configure gd --with-freetype --with-jpeg; \
        docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
        docker-php-ext-configure ldap --with-libdir="lib/$debMultiarch"; \
        docker-php-ext-install -j "$(nproc)" \
                exif \
                gd \
                imap \
                ldap \
                mbstring \
                pdo \
                pdo_mysql \
                pdo_pgsql \
                pgsql \
                sodium \
                tidy \
                zip \
        ; \
        apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
        rm -rf /var/lib/apt/lists/*
COPY --from=build /src/limesurvey /var/www/limesurvey
RUN mkdir -p /var/log/limesurvey
RUN chown unit:unit -R /var/www/limesurvey /var/log/limesurvey 
COPY --chmod=555 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh 
COPY --chmod=666 --chown=unit:unit php.ini /var/www/limesurvey/php.ini
COPY --chmod=750 --chown=unit:unit unit.limesurvey.json /var/lib/limesurvey/docker-entrypoint.d/unit.limesurvey.json
COPY --chmod=660 --chown=unit:unit config.php /var/lib/limesurvey/config.php
COPY --chmod=555 --chown=unit:unit env.sh /usr/local/bin/lime-env
COPY limesurvey.service /etc/systemd/system/limesurvey.service
#TODO: I need more secure...
RUN chmod 777 /var/www/limesurvey/application/config/config.php
RUN chmod 777 /var/www/limesurvey/tmp/runtime/
#COPY --from=build --chmod=750 --chown=unit:unit /var/lib/limesurvey/* /var/lib/limesurvey/
