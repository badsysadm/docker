FROM debian:bullseye-20240211-slim AS waf
RUN apt-get update -y && apt-get install -y dirmngr curl
RUN curl -fsSL https://repo.webmonitorx.ru/wmx.gpg | apt-key add -
RUN sh -c "echo 'deb https://repo.webmonitorx.ru/debian/webmonitorx-node bullseye/4.6/' | tee /etc/apt/sources.list.d/wmx.list"
RUN apt-get update -y && apt-get install -y --no-install-recommends wallarm-node-nginx nginx-module-wallarm
#COPY wallarm@register-node.service /etc/systemd/system/
