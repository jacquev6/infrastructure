FROM alpine:3.12

RUN apk add --no-cache py3-pip


WORKDIR /media-utils

COPY src/requirements.txt .

RUN pip install -r requirements.txt

COPY src .

ENTRYPOINT rq worker rip-dvds
