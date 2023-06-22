FROM alpine:latest

RUN apk update && apk upgrade
RUN apk --no-cache add curl
RUN apk --no-cache add zip
RUN apk --no-cache add bash
RUN apk --no-cache add perl-utils

COPY entrypoint.sh /entrypoint.sh

RUN ["chmod", "+x", "/entrypoint.sh"]

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]