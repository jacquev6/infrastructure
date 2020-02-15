#!/usr/bin/env python3

import subprocess

import click


@click.group()
def cli():
    pass


@cli.command()
def init():
    subprocess.run(["terraform", "init"], check=True)


@cli.command()
def refresh():
    subprocess.run(["terraform", "refresh"], check=True)


@cli.command()
def plan():
    subprocess.run(["terraform", "plan", "-refresh=false"], check=True)


@cli.command()
def apply():
    subprocess.run(["terraform", "apply", "-refresh=false", "-auto-approve"], check=True)


@cli.command(context_settings=dict(ignore_unknown_options=True, help_option_names=[]))
@click.argument("args", nargs=-1, type=click.UNPROCESSED)
def terraform(args):
    subprocess.run(["terraform"] + list(args), check=True)


@cli.command()
@click.argument("ip")
@click.argument("name")
def check_certificate(ip, name):
    subprocess.run(["openssl", "s_client", "-showcerts", "-servername", name, "-connect", ip + ":443"], check=True, input="")


if __name__ == "__main__":
    cli()
