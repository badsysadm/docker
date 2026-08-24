FROM alpine:latest AS base
RUN apk update && apk add git make bash nodejs npm curl
WORKDIR /src/n8n
RUN npm install -g n8n@0.126.1
RUN npm install -g n8n@next

FROM alpine:latest
RUN apk update && apk add nodejs
COPY --from=base /usr/local /usr/local/
ENV HOME=/var/lib/n8n
CMD ["n8n", "start"]
