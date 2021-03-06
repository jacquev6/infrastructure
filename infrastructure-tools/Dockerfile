FROM ubuntu:20.04 AS base

# https://stackoverflow.com/a/44333806/905845
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime

RUN apt-get update
RUN apt-get install --yes wget unzip golang git build-essential



FROM base AS terraform
LABEL infrastructure-tools-builder-stage=terraform

# https://www.terraform.io/downloads.html
RUN wget https://releases.hashicorp.com/terraform/0.12.20/terraform_0.12.20_linux_amd64.zip
RUN unzip terraform_0.12.20_linux_amd64.zip

ARG version
LABEL infrastructure-tools-builder-version=$version



FROM base AS terraform_provider_gandi
LABEL infrastructure-tools-builder-stage=terraform_provider_gandi

WORKDIR /mygo
RUN wget https://dl.google.com/go/go1.13.8.linux-amd64.tar.gz
RUN tar zxf go1.13.8.linux-amd64.tar.gz
WORKDIR /
ENV PATH=/mygo/go/bin:$PATH

RUN git clone https://github.com/tiramiseb/terraform-provider-gandi.git
RUN cd terraform-provider-gandi && git checkout v1.1.1 && go build

ARG version
LABEL infrastructure-tools-builder-version=$version



FROM base AS terraform_provider_uptimerobot
LABEL infrastructure-tools-builder-stage=terraform_provider_uptimerobot

WORKDIR /mygo
RUN wget https://dl.google.com/go/go1.13.8.linux-amd64.tar.gz
RUN tar zxf go1.13.8.linux-amd64.tar.gz
WORKDIR /
ENV PATH=/mygo/go/bin:$PATH

RUN git clone https://github.com/louy/terraform-provider-uptimerobot.git
RUN cd terraform-provider-uptimerobot && go build

ARG version
LABEL infrastructure-tools-builder-version=$version



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

ARG version
LABEL infrastructure-tools-builder-version=$version


FROM base AS kubectl
LABEL infrastructure-tools-builder-stage=kubectl

RUN wget https://dl.k8s.io/release/v1.20.5/bin/linux/amd64/kubectl
RUN chmod +x kubectl

ARG version
LABEL infrastructure-tools-builder-version=$version


FROM ubuntu:20.04

# https://stackoverflow.com/a/44333806/905845
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime

RUN set -x \
    && apt-get update \
    && apt-get install --yes \
      python3-pip \
      ssh sshpass \
    && rm -rf /var/lib/apt/lists/*
RUN pip3 install click requests ansible terraform-provider-freebox

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

COPY --from=terraform /terraform /usr/local/bin/
COPY --from=terraform_provider_gandi /terraform-provider-gandi/terraform-provider-gandi /usr/local/bin/
COPY --from=terraform_provider_uptimerobot /terraform-provider-uptimerobot/terraform-provider-uptimerobot /usr/local/bin/
COPY --from=terraform_provider_multiverse /root/go/bin/terraform-provider-multiverse /usr/local/bin/
COPY --from=kubectl /kubectl /usr/local/bin/

WORKDIR /infra
COPY infra.py .
COPY terraform-provider-multiverse-freebox.py .
