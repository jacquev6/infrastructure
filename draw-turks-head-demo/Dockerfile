FROM alpine:3.8 AS builder

RUN apk add boost-dev python2-dev cairomm-dev g++ pkgconf-dev py2-pip strace
RUN pip install DrawTurksHead==0.3.5 gunicorn==19.9.0

# Make a list of files actually required
# This is the tricky part. The following can help:
# - cat /proc/1/maps
# - strace -f -e trace=open -o trace.log /usr/bin/gunicorn -w 3 -b :80 wsgi:app
# - docker run --security-opt seccomp:unconfined --rm --name demo -p 8080:80 jacquev6/draw-turks-head-demo:latest-built-on-idee
# (Required to run strace inside Docker)
COPY list.txt /list.txt
WORKDIR /collected
RUN for f in $(grep "^/" /list.txt); do mkdir -p .$(dirname $f); cp $f .$(dirname $f); done


FROM scratch

COPY --from=builder /collected /

EXPOSE 80

CMD ["/usr/bin/gunicorn", "-w", "3", "-b", ":80", "wsgi:app"]

COPY wsgi.py .
