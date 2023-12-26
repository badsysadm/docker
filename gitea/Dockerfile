FROM alpine:latest
ENV GITEA_WORK_DIR /var/lib/gitea/
RUN apk update && apk add git
RUN adduser \
   --system \
   --shell /bin/bash \
   --gecos 'Git Version Control' \
   --disabled-password \
   --home /home/git \
   git
RUN mkdir -p /var/lib/gitea/custom /var/lib/gitea/data /var/lib/gitea/log /etc/systemd/system/
RUN chown -R git /var/lib/gitea/
RUN chmod -R 750 /var/lib/gitea/
RUN mkdir /etc/gitea
RUN chown git /etc/gitea
RUN chmod 770 /etc/gitea
RUN wget -O /usr/local/bin/gitea https://dl.gitea.com/gitea/1.21.2/gitea-1.21.2-linux-amd64
RUN chmod +x /usr/local/bin/gitea
COPY gitea.service /etc/systemd/system/gitea.service
CMD ["/usr/local/bin/gitea", "web", "-c", "/etc/gitea/app.ini"]