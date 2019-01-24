#!/usr/bin/env python3

import os
import shutil
import subprocess
import sys

sys.argv[0] = "./infra.sh"

import click

@click.group()
def cli():
    pass


@cli.command()
def init():
    try:
        shutil.rmtree(".terraform")
    except FileNotFoundError:
        pass
    os.makedirs(".terraform/plugins/linux_amd64")
    shutil.copy("/root/go/bin/terraform-provider-gandi", ".terraform/plugins/linux_amd64")
    subprocess.run(["/usr/local/bin/terraform", "init"], check=True)


@cli.command()
def plan():
    subprocess.run(["/usr/local/bin/terraform", "plan"], check=True)


@cli.command()
def apply():
    subprocess.run(["/usr/local/bin/terraform", "apply", "-auto-approve"], check=True)


if __name__ == "__main__":
    cli()
