FROM ubuntu:18.04

RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        python3.7 python3-pip \
        wget unzip golang git \
    && rm -rf /var/lib/apt/lists/*

RUN cd /usr/local/bin \
    && wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip \
    && unzip terraform_0.11.11_linux_amd64.zip

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go get -a -tags netgo -ldflags '-w -extldflags "-static"' github.com/tiramiseb/terraform-provider-gandi

RUN cd /usr/local/bin \
    && wget https://storage.googleapis.com/kubernetes-release/release/v1.13.2/bin/linux/amd64/kubectl \
    && chmod +x kubectl

RUN cd / \
    && wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-231.0.0-linux-x86_64.tar.gz \
    && tar xzf google-cloud-sdk-231.0.0-linux-x86_64.tar.gz

RUN cd /usr/local/bin \
    && wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.7.0/kubeseal-linux-amd64 \
    && chmod +x kubeseal-linux-amd64


# @todo Why do we have wget? Is it from the base image? Seems unnecessary
FROM python:2.7.15-alpine3.8

# @todo Don't add gcc and musl-dev. We should be able to use multi-stage build to run pip and copy the installed packages
RUN apk add --no-cache openssl gcc musl-dev
RUN pip install click==7.0 subprocess32==3.5.3

COPY --from=0 /usr/local/bin/terraform /usr/local/bin/
COPY --from=0 /root/go/bin/terraform-provider-gandi /usr/local/bin/
COPY --from=0 /usr/local/bin/kubectl /usr/local/bin/
COPY --from=0 /usr/local/bin/kubeseal-linux-amd64 /usr/local/bin/kubeseal
COPY --from=0 /google-cloud-sdk/ /
RUN cd /usr/local/bin && ln -s /google-cloud-sdk/bin/gcloud .

VOLUME /ssh
VOLUME /sources
WORKDIR /sources

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENTRYPOINT ["python", "/entry-point.py"]

COPY entry-point.py /
