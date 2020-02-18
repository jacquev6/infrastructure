#!/usr/bin/env python

import datetime
import smtplib
import time


def main():
    start = datetime.datetime.now()
    while True:
        time.sleep(3 * 3600)
        remind(start)


def remind(start):
    now = datetime.datetime.now()

    from_ = "no-reply@vincent-jacques.net"
    to = "jacquev6@gmail.com"
    subject = f"idee has been running for {now - start}"
    body = f"Did you forget to shut it down?"

    s = smtplib.SMTP_SSL(host="mail.gandi.net", port=465)
    s.set_debuglevel(2)
    s.login("no-reply@vincent-jacques.net", "${gandi_smtp_password}")
    s.sendmail(from_, to, f"From: {from_}\r\nTo: {to}\r\nSubject: {subject}\r\n\r\n{body}")
    s.quit()

    print(subject, flush=True)


if __name__ == "__main__":
    main()
