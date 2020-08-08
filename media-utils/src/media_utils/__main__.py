import datetime
import fcntl
import itertools
import os
import time

import click
import rq
import redis

from .rip_dvd import rip_dvd


redis_connection = None


@click.group()
@click.option("--redis-url")
def main(redis_url):
    global redis_connection
    redis_connection = redis.Redis.from_url(redis_url)


@main.command()
@click.argument("devices", nargs=-1)
@click.argument("data_path", nargs=1)
def chain_rip(devices, data_path):
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
                    print("Start ripping from", device)
                    rip_jobs[device] = rip_dvds.enqueue(rip_dvd, device, os.path.join(data_path, "new"), now)

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
