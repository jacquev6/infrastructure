import datetime
import fcntl
import itertools
import os
import smtplib
import time
import urllib.parse

import click
import rq
import redis

from .rip_dvd import rip_dvd
from .check_iso import check_iso


redis_connection = None
smtp = None


@click.group()
@click.option("--redis-url")
@click.option("--smtp-url")
def main(redis_url, smtp_url):
    global redis_connection
    redis_connection = redis.Redis.from_url(redis_url)
    global smtp
    smtp = urllib.parse.urlsplit(smtp_url)


@main.command()
@click.option("--mail-to")
@click.argument("devices", nargs=-1)
@click.argument("data_path", nargs=1)
def chain_rip(mail_to, devices, data_path):
    print("Chain ripping from the following devices:", " ".join(devices), flush=True)

    rip_dvds = rq.Queue(name="rip-dvds", default_timeout="2h", connection=redis_connection)

    rip_dvds.empty()
    rip_jobs = {
        job.args[0]: job
        for job in rq.job.Job.fetch_many(
            list(rip_dvds.started_job_registry.get_job_ids()),
            connection=redis_connection,
        )
    }

    check = rq.Queue(name="check", default_timeout="2h", connection=redis_connection)

    check.empty()
    check_jobs = {
        job.args[0]: job
        for job in rq.job.Job.fetch_many(
            list(check.started_job_registry.get_job_ids()),
            connection=redis_connection,
        )
    }

    mail_sent = False

    while True:
        now = datetime.datetime.now()
        print("Polling loop at", now, flush=True)

        for device, job in dict(rip_jobs).items():
            job: rq.job.Job
            if job.is_queued:
                print("Ripping from", device, "still queued... Do you have enough workers?")
            elif job.is_started:
                print("Still ripping from", device)
            elif job.is_finished:
                print("Done ripping from", device)
                del rip_jobs[device]
            elif job.is_failed:
                print("FAILED ripping from", device)
                del rip_jobs[device]
            else:
                assert False, f"UNEXPECTED job status for {device}: {job.get_status()}"

        for device in devices:
            if device not in rip_jobs:
                if has_disk(device):
                    mail_sent = False
                    print("Start ripping from", device)
                    rip_jobs[device] = rip_dvds.enqueue(rip_dvd, device, os.path.join(data_path, "new"), now)

        if mail_to and not mail_sent and not rip_jobs:
            mail_sent = True
            s = smtplib.SMTP_SSL(host=smtp.hostname, port=smtp.port)
            s.login(smtp.username, smtp.password)
            s.sendmail(
                smtp.username,
                mail_to,
                f"From: {smtp.username}\r\nTo: {mail_to}\r\nSubject: Chain rip is idle - {now} - TSIA\r\n\r\n",
            )
            s.quit()

        for file_name, job in dict(check_jobs).items():
            job: rq.job.Job
            if job.is_queued:
                print("Checking", file_name, "still queued")
            elif job.is_started:
                print("Still checking", file_name)
            elif job.is_finished:
                print("Done checking", file_name)
                del check_jobs[file_name]
            elif job.is_failed:
                print("FAILED checking", file_name)
                del check_jobs[file_name]
            else:
                assert False, f"UNEXPECTED job status for {file_name}: {job.get_status()}"

        for file_name in os.listdir(os.path.join(data_path, "new")):
            file_path = os.path.join(data_path, "new", file_name)
            if file_path.endswith(".iso") and file_path not in check_jobs:
                print("Enqueue checking", file_path)
                check_jobs[file_path] = check.enqueue(
                    check_iso,
                    file_path,
                    os.path.join(data_path, "checked"),
                    os.path.join(data_path, "errors"),
                )

        print(flush=True)
        time.sleep(10)


def has_disk(device):
    # https://superuser.com/a/1367091/517309
    fd = os.open(device, os.O_RDONLY | os.O_NONBLOCK)
    try:
        return fcntl.ioctl(fd, 0x5326) == 4
    finally:
        os.close(fd)


if __name__ == "__main__":
    main(auto_envvar_prefix="MEDIA_UTILS")
