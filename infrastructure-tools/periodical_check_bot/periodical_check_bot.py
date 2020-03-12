#!/usr/bin/env python3

import datetime
import os
import smtplib
import stat
import subprocess
import time

import click

@click.command()
@click.option("--period", type=int)
def main(period):
    os.chmod("/root/.ssh/id_rsa", stat.S_IRUSR)
    if period is None:
        check()
    else:
        check()
        while True:
            time.sleep(period)
            check()


def check():
    # Work around DNS resolution problems...
    for i in range(20):
        ps = subprocess.run(
            [
                "ssh", "jacquev6@idee.home.jacquev6.net", "ps", "faux",
            ],
            capture_output=True,
            universal_newlines=True,
        )
        if ps.returncode == 0:
            break
        time.sleep(2)

    from_ = "no-reply@vincent-jacques.net"
    to = "jacquev6@gmail.com"
    subject = f"Periodical check bot report"
    body = f"ps faux:\n{ps.stderr}{ps.stdout}"
    s = smtplib.SMTP_SSL(host="mail.gandi.net", port=465)
    s.set_debuglevel(2)
    s.login(from_, os.environ["GANDI_SMTP_PASSWORD"])
    s.sendmail(from_, to, f"From: {from_}\r\nTo: {to}\r\nSubject: {subject}\r\n\r\n{body}")
    s.quit()


if __name__ == "__main__":
    main()
