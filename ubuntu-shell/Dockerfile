FROM ubuntu:19.10

RUN apt-get update \
 && apt-get upgrade --yes \
 && yes | unminimize \
 && apt-get install --yes --no-install-recommends \
      python3 openssh-server sudo docker.io \
 && rm -rf /var/lib/apt/lists/* \
 && cd /etc/ssh/ \
 && mkdir host_keys/ \
 && mv ssh_host_*_key ssh_host_*_key.pub host_keys/ \
 && ln -s host_keys/* . \
 && rm host_keys/*

COPY ubuntu_shell.py /
ENTRYPOINT ["/ubuntu_shell.py", "/ubuntu_shell.json"]
