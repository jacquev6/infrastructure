FROM ubuntu:22.04 AS base

# https://docs.docker.com/engine/reference/builder/#run---mounttypecache
RUN set -x \
 && rm -f /etc/apt/apt.conf.d/docker-clean \
 && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache


FROM base AS downloader

# System packages
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -x \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
      ca-certificates \
      unzip \
      wget \
 && true

WORKDIR /download


FROM downloader AS download-awscli

RUN wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
 && unzip awscli-*.zip \
 && rm awscli-*.zip \
 && mv aws awscli


FROM downloader AS download-session-manager-plugin

RUN wget https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb


FROM base AS final

# System packages
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -x \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
      bind9-dnsutils  `# For dig` \
      gnupg \
      less \
      openssh-client \
      python3-pip \
      software-properties-common \
      sshpass \
      wget \
 && true

# Terraform
# From the "Linux" tab on https://developer.hashicorp.com/terraform/downloads
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -x \
 && wget -O- https://apt.releases.hashicorp.com/gpg \
  | gpg --dearmor \
  >/usr/share/keyrings/hashicorp-archive-keyring.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  >/etc/apt/sources.list.d/hashicorp.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
      terraform \
 && true

RUN terraform -install-autocomplete

# AWS CLI
RUN --mount=type=bind,from=download-awscli,source=/download,target=/download,readwrite \
    set -x \
 && /download/awscli/install

RUN --mount=type=bind,from=download-session-manager-plugin,source=/download,target=/download,readwrite \
    set -x \
 && dpkg -i /download/session-manager-plugin.deb

# Ansible
RUN --mount=type=cache,target=/root/.cache/pip,sharing=locked \
    set -x \
 && pip3 install \
      ansible \
 && true

# User
ARG USER_NAME
ARG USER_ID
RUN useradd $USER_NAME --uid $USER_ID --create-home
USER $USER_NAME
