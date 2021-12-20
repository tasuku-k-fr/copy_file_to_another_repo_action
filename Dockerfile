FROM alpine:3.14

RUN apk update && \
    apk upgrade && \
    apk add git && \
    apk add rsync

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
