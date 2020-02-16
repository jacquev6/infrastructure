#!/usr/bin/env python3

import subprocess

import click


@click.group()
def cli():
    pass


@cli.command()
def init():
    delegate_to("terraform", "init")


@cli.command()
def refresh():
    delegate_to("terraform", "refresh")


@cli.command()
def plan():
    delegate_to("terraform", "plan", "-refresh=false")


@cli.command()
def apply():
    delegate_to("terraform", "apply", "-refresh=false", "-auto-approve")


@cli.command(context_settings=dict(ignore_unknown_options=True, help_option_names=[]))
@click.argument("args", nargs=-1, type=click.UNPROCESSED)
def terraform(args):
    delegate_to("terraform", *args)


@cli.command()
@click.argument("ip")
@click.argument("name")
def check_certificate(ip, name):
    delegate_to("openssl", "s_client", "-showcerts", "-servername", name, "-connect", ip + ":443", input="")


def delegate_to(*args, **kwds):
  assert "check" not in kwds
  exit(subprocess.run(args, **kwds).returncode)



if __name__ == "__main__":
    cli()
