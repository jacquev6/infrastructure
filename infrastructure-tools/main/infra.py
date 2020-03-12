#!/usr/bin/env python3

import json
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
    refresh_data_sources()
    delegate_to("terraform", "plan", "-refresh=false")


@cli.command()
def apply():
    refresh_data_sources()
    delegate_to("terraform", "apply", "-refresh=false", "-auto-approve")


def refresh_data_sources():
    resources = subprocess.check_output(["terraform", "state", "list"], universal_newlines=True)
    targets = [f"-target={resource}" for resource in resources.splitlines() if ".data." in resource]
    subprocess.run(["terraform", "refresh"] + targets, check=True)


@cli.command(context_settings=dict(ignore_unknown_options=True, help_option_names=[]))
@click.argument("args", nargs=-1, type=click.UNPROCESSED)
def terraform(args):
    delegate_to("terraform", *args)


@cli.command()
@click.argument("ip")
@click.argument("name")
def check_certificate(ip, name):
    delegate_to("openssl", "s_client", "-showcerts", "-servername", name, "-connect", ip + ":443", input="")


@cli.group()
def freebox():
    pass


@freebox.command()
def login():
    delegate_to("/terraform-provider-multiverse-freebox.py", "login")


@freebox.command()
@click.argument("path")
def get(path):
    delegate_to("/terraform-provider-multiverse-freebox.py", "get", path)


def delegate_to(*args, **kwds):
    assert "check" not in kwds
    try:
        exit(subprocess.run(args, **kwds).returncode)
    finally:
        if args[0] == "terraform":
            stabilize_terraform_state()


def stabilize_terraform_state():
    with open("terraform.tfstate") as f:
        state = json.load(f)
    # Keep resources sorted
    state["resources"] = sorted(state["resources"], key=lambda r: ".".join([r["module"], r["mode"], r["type"], r["name"]]))
    # Remove changing id
    for resource in state["resources"]:
        if resource["type"] == "uptimerobot_account":
            for instance in resource["instances"]:
                instance["attributes"].pop("id", None)
    with open("terraform.tfstate", "w") as f:
        json.dump(state, f, sort_keys=True, indent=2)


if __name__ == "__main__":
    cli()
