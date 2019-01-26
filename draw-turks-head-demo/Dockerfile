FROM python:2.7.15-stretch

RUN apt-get update \
    && apt-get install --no-install-recommends --yes build-essential libcairomm-1.0-dev libboost-dev libboost-python-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN pip install DrawTurksHead==0.3.5 gunicorn==19.9.0

COPY wsgi.py .

EXPOSE 80

CMD ["gunicorn", "-w 3", "-b :80", "wsgi:app"]
