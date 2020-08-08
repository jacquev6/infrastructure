# Because Alpine's "eject" command fails with I/O error with DVDs
FROM ubuntu:20.04

# https://stackoverflow.com/a/44333806/905845
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes \
      python3-pip \
      libdvd-pkg \
      genisoimage \
    eject \
 && rm -rf /var/lib/apt/lists/*

# Install libdvdcss
RUN dpkg-reconfigure libdvd-pkg


RUN mkdir python-dvdvideo \
 && cd python-dvdvideo \
 && wget http://archive.ubuntu.com/ubuntu/pool/universe/p/python-dvdvideo/python-dvdvideo_0.20140413.tar.xz \
 && tar xf python-dvdvideo_0.20140413.tar.xz \
 && pip3 install ./python-dvdvideo \
 && cd .. \
 && rm -rf python-dvdvideo


WORKDIR /media-utils

COPY src/requirements.txt .

RUN pip3 install -r requirements.txt

COPY src .

ENTRYPOINT rq worker rip-dvds
