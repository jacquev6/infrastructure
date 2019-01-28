FROM alpine:3.8 AS builder

RUN apk add boost-dev
RUN apk add python2-dev
RUN apk add cairomm-dev
RUN apk add g++
RUN apk add pkgconf-dev

RUN apk add py2-pip
RUN pip install DrawTurksHead==0.3.5 gunicorn==19.9.0


FROM alpine:3.8 AS collector

RUN apk add --no-cache boost-python cairomm

COPY --from=builder /usr/lib/python2.7/site-packages/DrawTurksHead/ /usr/lib/python2.7/site-packages/DrawTurksHead/
COPY --from=builder /usr/lib/python2.7/site-packages/cairo/ /usr/lib/python2.7/site-packages/cairo/
COPY --from=builder /usr/lib/python2.7/site-packages/gunicorn/ /usr/lib/python2.7/site-packages/gunicorn/
COPY --from=builder /usr/lib/python2.7/site-packages/pkg_resources/ /usr/lib/python2.7/site-packages/pkg_resources/
COPY --from=builder /usr/bin/gunicorn /usr/bin/


FROM scratch

COPY --from=collector / /

WORKDIR /app

EXPOSE 80

CMD ["gunicorn", "-w 3", "-b :80", "wsgi:app"]

COPY wsgi.py .
