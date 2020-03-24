FROM ubuntu:19.10

RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
      python3 python3-pip vorbis-tools graphviz \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install click setuptools
RUN pip3 install ActionTree[dependency_graphs]

ENTRYPOINT ["python3", "-m", "media-utils"]

COPY media-utils /media-utils
