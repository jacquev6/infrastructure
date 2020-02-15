FROM ubuntu:18.04 AS base
RUN apt-get update
RUN apt-get install --yes wget unzip golang git



FROM base AS terraform
LABEL infrastructure-tools-builder-stage=terraform

# https://www.terraform.io/downloads.html
RUN wget https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_linux_amd64.zip
RUN unzip terraform_0.11.14_linux_amd64.zip

ARG tag
LABEL infrastructure-tools-builder-tag=$tag



FROM base AS terraform_provider_gandi
LABEL infrastructure-tools-builder-stage=terraform_provider_gandi

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go get -a -tags netgo -ldflags '-w -extldflags "-static"' github.com/tiramiseb/terraform-provider-gandi

ARG tag
LABEL infrastructure-tools-builder-tag=$tag



FROM ubuntu:18.04

RUN set -x \
    && apt-get update \
    && apt-get install --yes --no-install-recommends python3-pip ssh \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install click==7.0

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

COPY --from=terraform /terraform /usr/local/bin/
COPY --from=terraform_provider_gandi /root/go/bin/terraform-provider-gandi /usr/local/bin/

WORKDIR /infrastructure/sources
COPY infra.py /
