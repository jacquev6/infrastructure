FROM alpine:3.11

RUN apk add python3 iperf3
RUN pip3 install gunicorn

CMD ["/usr/bin/gunicorn", "-w", "3", "-b", ":80", "wsgi:app"]

COPY wsgi.py /
