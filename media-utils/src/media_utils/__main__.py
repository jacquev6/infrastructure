import datetime
import fcntl
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
def chain_rip(devices):
    print("Chain ripping from the following devices:", " ".join(devices), flush=True)

    rip_dvds = rq.Queue(name="rip-dvds", connection=redis_connection)

    while True:
        print("Polling loop at", datetime.datetime.now(), flush=True)
        devices_being_ripped = set(job.args[0] for job in rip_dvds.get_jobs())
        print("Devices being ripped:", " ".join(devices_being_ripped))
        for device in devices:
            if device not in devices_being_ripped and has_disk(device):
                print("Ripping from", device)
                rip_dvds.enqueue(rip_dvd, device)

        print(flush=True)
        time.sleep(10)


def has_disk(device):
    fd = os.open(device, os.O_RDONLY | os.O_NONBLOCK)
    try:
        return fcntl.ioctl(fd, 0x5326) == 4
    finally:
        os.close(fd)


if __name__ == "__main__":
    main(auto_envvar_prefix="MEDIA_UTILS")
