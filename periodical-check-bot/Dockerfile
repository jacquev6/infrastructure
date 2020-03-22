FROM alpine:3.11

RUN apk add python3 openssh-client
RUN pip3 install click

ENTRYPOINT ["/periodical_check_bot.py"]

COPY periodical_check_bot.py /
