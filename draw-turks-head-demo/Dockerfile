FROM alpine:3.8 AS builder

RUN apk add boost-dev python2-dev cairomm-dev g++ pkgconf-dev py2-pip strace
# Freeze pycairo to the last version supporting Python 2
RUN pip install pycairo==1.18.2
RUN pip install DrawTurksHead==0.3.5 gunicorn==19.9.0

# Make a list of files actually required.
# This is in the same spirit as https://github.com/GoogleContainerTools/distroless
# but pushed to the extreme: each file we keep is required to run the application.
# This is the tricky part. The following can help:
# - cat /proc/1/maps
# - strace -f -e trace=open -o trace.log /usr/bin/gunicorn -w 3 -b :80 wsgi:app
# - docker run --security-opt seccomp:unconfined --rm --name demo -p 8080:80 jacquev6/draw-turks-head-demo:latest-built-on-idee
# (Required to run strace inside Docker)
COPY list.txt /list.txt
WORKDIR /collected
RUN mkdir lib; cp /lib/ld-musl-*.so.1 lib
RUN for f in $(grep "^/" /list.txt); do mkdir -p .$(dirname $f); cp $f .$(dirname $f); done


FROM scratch

COPY --from=builder /collected /

EXPOSE 80

CMD ["/usr/bin/gunicorn", "-w", "3", "-b", ":80", "wsgi:app"]

COPY wsgi.py .
