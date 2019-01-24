FROM ubuntu:18.04

RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        python3.7 python3-pip \
        wget unzip golang git \
    && rm -rf /var/lib/apt/lists/*

RUN cd /usr/local/bin \
    && wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip \
    && unzip terraform_0.11.11_linux_amd64.zip

RUN go get github.com/tiramiseb/terraform-provider-gandi

RUN pip3 install click==7.0

# @todo Use multi-stage build: https://docs.docker.com/develop/develop-images/multistage-build/ (for terraform itself, terraform-provider-gandi, and python dependencies)

VOLUME /ssh
VOLUME /sources
WORKDIR /sources

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENTRYPOINT ["/usr/bin/env", "python3", "/entry-point.py"]

COPY entry-point.py /
