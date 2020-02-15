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



FROM base AS kubectl
LABEL infrastructure-tools-builder-stage=kubectl

# https://storage.googleapis.com/kubernetes-release/release/stable.txt
RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.13.2/bin/linux/amd64/kubectl
RUN chmod +x kubectl

ARG tag
LABEL infrastructure-tools-builder-tag=$tag



FROM base AS google_cloud_sdk
LABEL infrastructure-tools-builder-stage=google_cloud_sdk

# https://cloud.google.com/sdk/docs/downloads-versioned-archives
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-231.0.0-linux-x86_64.tar.gz
RUN tar xzf google-cloud-sdk-231.0.0-linux-x86_64.tar.gz

ARG tag
LABEL infrastructure-tools-builder-tag=$tag



FROM base AS kubeseal
LABEL infrastructure-tools-builder-stage=kubeseal

# https://github.com/bitnami-labs/sealed-secrets/releases
RUN wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.7.0/kubeseal-linux-amd64
RUN chmod +x kubeseal-linux-amd64

ARG tag
LABEL infrastructure-tools-builder-tag=$tag



FROM base AS helm
LABEL infrastructure-tools-builder-stage=helm

RUN wget https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-linux-amd64.tar.gz
RUN tar xzf helm-v2.11.0-linux-amd64.tar.gz

ARG tag
LABEL infrastructure-tools-builder-tag=$tag



FROM ubuntu:18.04

RUN set -x \
    && apt-get update \
    && apt-get install --yes --no-install-recommends \
        python python3-pip python3-setuptools git ssh \
        groff \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install awscli==1.16 click==7.0 pyyaml==3.13

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

COPY --from=terraform /terraform /usr/local/bin/
COPY --from=kubectl /kubectl /usr/local/bin/
COPY --from=kubeseal /kubeseal-linux-amd64 /usr/local/bin/kubeseal
COPY --from=google_cloud_sdk /google-cloud-sdk/ /
RUN cd /usr/local/bin && ln -s /google-cloud-sdk/bin/gcloud .
COPY --from=helm /linux-amd64/helm /usr/local/bin/
RUN helm init --client-only
COPY --from=terraform_provider_gandi /root/go/bin/terraform-provider-gandi /usr/local/bin/

WORKDIR /infrastructure/sources
COPY infra /
