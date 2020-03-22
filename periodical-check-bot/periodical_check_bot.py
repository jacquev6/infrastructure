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
@click.argument("user")
@click.argument("host")
@click.argument("to")
@click.option("--delay", type=int, default=0)
@click.option("--period", type=int, default=None)
def main(user, host, to, delay, period):
    smtp_host = os.environ.get("SMTP_HOST")
    smtp_port = os.environ.get("SMTP_PORT")
    smtp_user = os.environ.get("SMTP_USER")
    smtp_password = os.environ.get("SMTP_PASSWORD")
    if smtp_host and smtp_port and smtp_user and smtp_password:
        message_factory = lambda subject, body: EmailMessage(smtp_host, int(smtp_port), smtp_user, smtp_password, to, subject, body)
    else:
        message_factory = PrintableMessage

    checker = Checker(user, host, datetime.timedelta(seconds=delay), message_factory)

    checker.check()
    if period is not None:
        while True:
            time.sleep(period)
            checker.check()


class Checker:
    def __init__(self, user, remote, delay, message_factory):
        self.__user = user
        self.__remote = remote
        self.__delay = delay
        self.__message_factory = message_factory

    def check(self):
        self.__debug("checking")
        uptime = self.__run_on_remote("uptime", "--since")
        if uptime.returncode == 0:
            # remote's timezone could be different from host's, so we need to subtract
            # two remote datetimes to get an accurate timedelta
            startup_datetime = datetime.datetime.strptime(
                uptime.stdout.strip(),
                "%Y-%m-%d %H:%M:%S",
            )
            current_datetime = datetime.datetime.strptime(
                self.__run_on_remote("date", "--rfc-3339=seconds").stdout.strip()[:19],
                "%Y-%m-%d %H:%M:%S",
            )
            running_for = current_datetime - startup_datetime

            self.__debug(f"running for {running_for} (compared to {self.__delay})")

            if running_for > self.__delay:
                ps = self.__run_on_remote("ps", "faux")
                smi = self.__run_on_remote("nvidia-smi")

                self.__message_factory(
                    f"{self.__remote} has been running for {running_for}",
                    textwrap.dedent("""\
                        Did you forget to turn if off?

                        Here is what it's doing:

                    """) + smi.stdout + ps.stdout,
                ).send()
                self.__debug("message sent")
        else:
            self.__debug("down (or inaccessible), nothing to check")

    def __debug(self, *args):
        print(f"{self.__user}@{self.__remote}:", *args, flush=True)

    def __run_on_remote(self, *args):
        return subprocess.run(
            ["ssh", f"{self.__user}@{self.__remote}"] + list(args),
            capture_output=True,
            universal_newlines=True,
        )


class PrintableMessage:
    def __init__(self, subject, body):
        self.__subject = subject
        self.__body = body

    def send(self):
        print("Subject:", self.__subject)
        print()
        print(self.__body, flush=True)


class EmailMessage:
    def __init__(self, smtp_host, smtp_port, smtp_user, smtp_password, to, subject, body):
        self.__smtp_host = smtp_host
        self.__smtp_port = smtp_port
        self.__smtp_user = smtp_user
        self.__smtp_password = smtp_password
        self.__to = to
        self.__subject = subject
        self.__body = body

    def send(self):
        s = smtplib.SMTP_SSL(host=self.__smtp_host, port=self.__smtp_port)
        s.login(self.__smtp_user, self.__smtp_password)
        s.sendmail(
            self.__smtp_user,
            self.__to,
            f"From: {self.__smtp_user}\r\nTo: {self.__to}\r\nSubject: {self.__subject}\r\n\r\n{self.__body}",
        )
        s.quit()


if __name__ == "__main__":
    # Workaround for permissions issue when copying the file into a Docker container using Terraform
    try:
        os.chmod("/root/.ssh/id_rsa", stat.S_IRUSR)
    except OSError:
        pass
    # End of workaround
    main()
