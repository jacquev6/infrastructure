#!/usr/bin/env python3

import json
import subprocess

import click


@click.group()
def cli():
    pass



@cli.group()
def tf():
    pass


@tf.command()
def init():
    delegate_to("terraform", "init", cwd="terraform")


@tf.command()
def refresh():
    delegate_to("terraform", "refresh", cwd="terraform")


@tf.command()
def plan():
    refresh_data_sources()
    delegate_to("terraform", "plan", "-refresh=false", cwd="terraform")


@tf.command()
def apply():
    refresh_data_sources()
    delegate_to("terraform", "apply", "-refresh=false", "-auto-approve", cwd="terraform")


def refresh_data_sources():
    resources = subprocess.check_output(["terraform", "state", "list"], universal_newlines=True, cwd="terraform")
    targets = [f"-target={resource}" for resource in resources.splitlines() if ".data." in resource]
    subprocess.run(["terraform", "refresh"] + targets, check=True, cwd="terraform")



@cli.command(context_settings=dict(ignore_unknown_options=True, help_option_names=[]))
@click.argument("args", nargs=-1, type=click.UNPROCESSED)
def raw(args):
    delegate_to(*args, cwd="terraform")



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
    delegate_to("/infra/terraform-provider-multiverse-freebox.py", "login")


@freebox.command()
@click.argument("path")
def get(path):
    delegate_to("/infra/terraform-provider-multiverse-freebox.py", "get", path)


def delegate_to(*args, **kwds):
    assert "check" not in kwds
    try:
        exit(subprocess.run(args, **kwds).returncode)
    finally:
        if args[0] == "terraform":
            stabilize_terraform_state()


def stabilize_terraform_state():
    with open("terraform/terraform.tfstate") as f:
        state = json.load(f)
    # Keep resources sorted
    state["resources"] = sorted(state["resources"], key=lambda r: ".".join([r["module"], r["mode"], r["type"], r["name"]]))
    # Remove changing id
    for resource in state["resources"]:
        if resource["type"] == "uptimerobot_account":
            for instance in resource["instances"]:
                instance["attributes"].pop("id", None)
    with open("terraform/terraform.tfstate", "w") as f:
        json.dump(state, f, sort_keys=True, indent=2)


if __name__ == "__main__":
    cli()
