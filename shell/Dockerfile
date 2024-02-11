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

# AWS CLI
RUN set -x \
 && wget -O awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip

RUN set -x \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
      unzip \
 && apt-get clean

RUN set -x \
 && unzip awscliv2.zip \
 && aws/install

RUN set -x \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
      less \
 && apt-get clean

RUN wget -O session-manager-plugin.deb "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb"
RUN dpkg -i session-manager-plugin.deb

RUN set -x \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
      openssh-client  `# For ssh-keygen` \
 && apt-get clean

RUN set -x \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
      bind9-dnsutils  `# For dig` \
 && apt-get clean

RUN set -x \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
      python3-pip \
 && apt-get clean
RUN pip3 install ansible
