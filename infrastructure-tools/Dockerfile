FROM ubuntu:18.04

RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        python3.7 python3-pip \
        wget unzip golang git \
    && rm -rf /var/lib/apt/lists/*

RUN cd /usr/local/bin \
    && wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip \
    && unzip terraform_0.11.11_linux_amd64.zip

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go get -a -tags netgo -ldflags '-w -extldflags "-static"' github.com/tiramiseb/terraform-provider-gandi


FROM python:3.7.2-alpine3.8

RUN pip install click==7.0
RUN apk add --no-cache openssl

COPY --from=0 /usr/local/bin/terraform /usr/local/bin/
COPY --from=0 /root/go/bin/terraform-provider-gandi /usr/local/bin/

VOLUME /ssh
VOLUME /sources
WORKDIR /sources

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENTRYPOINT ["python", "/entry-point.py"]

COPY entry-point.py /
