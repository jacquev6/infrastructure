FROM alpine:3.11

RUN apk add python3 iperf3 graphviz openssh-client
RUN pip3 install gunicorn

COPY known_hosts /root/.ssh/known_hosts

CMD ["/usr/bin/gunicorn", "-w", "3", "-b", ":80", "wsgi:app"]

COPY wsgi.py /
