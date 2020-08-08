FROM alpine:3.12

# *Do not* install libdvdcss: we want to validate that the isos are unencrypted
RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >>/etc/apk/repositories \
 && apk add --no-cache py3-pip handbrake@testing


WORKDIR /media-utils

COPY src/requirements.txt .

RUN pip install -r requirements.txt

COPY src .

ENTRYPOINT rq worker check
