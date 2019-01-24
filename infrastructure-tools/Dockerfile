FROM ubuntu:18.04

# @todo Run a single apt-get install
# @todo Clean-up apt package definition files after install
# @todo Use multi-stage build: https://docs.docker.com/develop/develop-images/multistage-build/ (for terraform itself, terraform-provider-gandi, and python dependencies)
RUN apt-get update
RUN apt-get install --yes python3.7 python3-pip
RUN pip3 install click==7.0
RUN apt-get install --yes wget
RUN cd /usr/local/bin && wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
RUN apt-get install --yes unzip
RUN cd /usr/local/bin && unzip terraform_0.11.11_linux_amd64.zip
RUN apt-get install --yes golang
RUN apt-get install --yes git
RUN go get github.com/tiramiseb/terraform-provider-gandi

VOLUME /sources
WORKDIR /sources

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENTRYPOINT ["/usr/bin/env", "python3", "/entry-point.py"]
CMD ["--help"]

COPY entry-point.py /
