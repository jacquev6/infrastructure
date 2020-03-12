FROM ubuntu:18.04 AS base
RUN apt-get update
RUN apt-get install --yes wget unzip golang git



FROM base AS terraform
LABEL infrastructure-tools-builder-stage=terraform

# https://www.terraform.io/downloads.html
RUN wget https://releases.hashicorp.com/terraform/0.12.20/terraform_0.12.20_linux_amd64.zip
RUN unzip terraform_0.12.20_linux_amd64.zip

ARG tag
LABEL infrastructure-tools-builder-tag=$tag



FROM base AS terraform_provider_gandi
LABEL infrastructure-tools-builder-stage=terraform_provider_gandi

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go get -a -tags netgo -ldflags '-w -extldflags "-static"' github.com/tiramiseb/terraform-provider-gandi

ARG tag
LABEL infrastructure-tools-builder-tag=$tag



FROM base AS terraform_provider_uptimerobot
LABEL infrastructure-tools-builder-stage=terraform_provider_uptimerobot

WORKDIR /mygo
RUN wget https://dl.google.com/go/go1.13.8.linux-amd64.tar.gz
RUN tar zxf go1.13.8.linux-amd64.tar.gz
WORKDIR /
ENV PATH=/mygo/go/bin:$PATH

RUN git clone https://github.com/louy/terraform-provider-uptimerobot.git
RUN cd terraform-provider-uptimerobot && go build

ARG tag
LABEL infrastructure-tools-builder-tag=$tag



FROM base AS terraform_provider_multiverse
LABEL infrastructure-tools-builder-stage=terraform_provider_multiverse

WORKDIR /mygo
RUN wget https://dl.google.com/go/go1.13.8.linux-amd64.tar.gz
RUN tar zxf go1.13.8.linux-amd64.tar.gz
WORKDIR /
ENV PATH=/mygo/go/bin:$PATH

# Using h0x91b-wix's fork until https://github.com/mobfox/terraform-provider-multiverse/issues/1 is fixed
RUN git clone https://github.com/h0x91b-wix/terraform-provider-multiverse.git
RUN cd terraform-provider-multiverse && make build

ARG tag
LABEL infrastructure-tools-builder-tag=$tag



FROM ubuntu:18.04

RUN set -x \
    && apt-get update \
    && apt-get install --yes --no-install-recommends python3-pip python3-setuptools ssh git \
    && rm -rf /var/lib/apt/lists/*
RUN pip3 install click==7.0 requests==2.22.0

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

COPY --from=terraform /terraform /usr/local/bin/
COPY --from=terraform_provider_gandi /root/go/bin/terraform-provider-gandi /usr/local/bin/
COPY --from=terraform_provider_uptimerobot /terraform-provider-uptimerobot/terraform-provider-uptimerobot /usr/local/bin/
COPY --from=terraform_provider_multiverse /root/go/bin/terraform-provider-multiverse /usr/local/bin/

WORKDIR /infrastructure/sources
COPY infra.py /
COPY terraform-provider-multiverse-freebox.py /
