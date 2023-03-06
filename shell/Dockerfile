FROM ubuntu:22.04

# System packages
RUN set -x \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
      wget software-properties-common gnupg \
 && apt-get clean

# Terraform
# From the "Linux" tab on https://developer.hashicorp.com/terraform/downloads
RUN set -x \
 && wget -O- https://apt.releases.hashicorp.com/gpg \
  | gpg --dearmor \
  >/usr/share/keyrings/hashicorp-archive-keyring.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  >/etc/apt/sources.list.d/hashicorp.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
      terraform \
 && apt-get clean

RUN terraform -install-autocomplete
