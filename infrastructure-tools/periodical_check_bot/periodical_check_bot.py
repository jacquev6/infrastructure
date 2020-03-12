#!/usr/bin/env python3

import datetime
import os
import smtplib
import stat
import subprocess
import textwrap
import time

import click

@click.command()
@click.option("--delay", type=int, default=0)
@click.option("--period", type=int, default=None)
def main(delay, period):
    os.chmod("/root/.ssh/id_rsa", stat.S_IRUSR)
    check(delay)
    if period is not None:
        while True:
            time.sleep(period)
            check(delay)


def check(delay):
    print("Checking", flush=True)
    uptime = run_on_idee("uptime", "--since")
    if uptime.returncode == 0:
        running_since = datetime.datetime.strptime(uptime.stdout.strip(), "%Y-%m-%d %H:%M:%S")
        running_for = datetime.datetime.now() - running_since

        # Work around time zone being UTC in the container
        running_for += datetime.timedelta(seconds=3600)

        if running_for > datetime.timedelta(seconds=delay):
            ps = run_on_idee("ps", "faux")
            smi = run_on_idee("nvidia-smi")

            message = Message(
                f"idee has been running for {running_for}",
                textwrap.dedent("""\
                    Did you forget to turn if off?

                    Here is what it's doing:

                """) + smi.stdout + ps.stdout,
            )

            gandi_smtp_password = os.environ.get("GANDI_SMTP_PASSWORD")
            if gandi_smtp_password is None:
                message.display()
            else:
                message.send(gandi_smtp_password)
    else:
        print("idee is down", flush=True)


class Message:
    def __init__(self, subject, body):
        self.__subject = subject
        self.__body = body

    def send(self, gandi_smtp_password):
        from_ = "no-reply@vincent-jacques.net"
        to = "jacquev6@gmail.com"
        s = smtplib.SMTP_SSL(host="mail.gandi.net", port=465)
        s.set_debuglevel(2)
        s.login(from_, gandi_smtp_password)
        s.sendmail(from_, to, f"From: {from_}\r\nTo: {to}\r\nSubject: {self.__subject}\r\n\r\n{self.__body}")
        s.quit()

    def display(self):
        print("Subject:", self.__subject)
        print()
        print(self.__body, flush=True)


def run_on_idee(*args):
    return subprocess.run(
        ["ssh", "jacquev6@idee.home.jacquev6.net"] + list(args),
        capture_output=True,
        universal_newlines=True,
    )


if __name__ == "__main__":
    main()
