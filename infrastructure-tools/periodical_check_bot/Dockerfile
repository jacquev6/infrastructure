FROM alpine:3.11

RUN apk add python3 openssh-client
RUN pip3 install click

ENTRYPOINT ["/periodical_check_bot.py"]

COPY known_hosts /root/.ssh/known_hosts
COPY periodical_check_bot.py /
