FROM python:2.7.15-stretch

RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        build-essential \
        libcairomm-1.0-dev \
        libboost1.62-dev \
        libboost-python1.62-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN pip install DrawTurksHead==0.3.5 gunicorn==19.9.0


FROM python:2.7.15-stretch

RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        libcairomm-1.0-1v5 \
        libboost-python1.62.0 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=0 /usr/local/lib/python2.7/site-packages/DrawTurksHead/ /usr/local/lib/python2.7/site-packages/DrawTurksHead/
COPY --from=0 /usr/local/lib/python2.7/site-packages/cairo/ /usr/local/lib/python2.7/site-packages/cairo/
COPY --from=0 /usr/local/lib/python2.7/site-packages/gunicorn/ /usr/local/lib/python2.7/site-packages/gunicorn/
COPY --from=0 /usr/local/bin/gunicorn /usr/local/bin/

WORKDIR /app

EXPOSE 80

CMD ["gunicorn", "-w 3", "-b :80", "wsgi:app"]

COPY wsgi.py .
