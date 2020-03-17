#!/usr/bin/env python3

import datetime
import json
import os
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
    delegate_to("terraform", "init")


@tf.command()
def refresh():
    delegate_to("terraform", "refresh")


@tf.command()
def plan():
    refresh_data_sources()
    delegate_to("terraform", "plan", "-refresh=false")


@tf.command()
def apply():
    refresh_data_sources()
    delegate_to("terraform", "apply", "-refresh=false", "-auto-approve")


def refresh_data_sources():
    resources = subprocess.check_output(["terraform", "state", "list"], universal_newlines=True, cwd="terraform")
    targets = [f"-target={resource}" for resource in resources.splitlines() if ".data." in resource]
    subprocess.run(["terraform", "refresh"] + targets, check=True, cwd="terraform")


@cli.group()
def an():
    pass


@an.command()
@click.argument("name")
def bootstrap_raspbian(name):
    playbooks = [
        os.path.join("bootstrap-raspbian", playbook)
        for playbook in sorted(os.listdir("ansible/bootstrap-raspbian"))
        if playbook.endswith(".yml")
    ] + [
        os.path.join("playbooks", playbook)
        for playbook in sorted(os.listdir("ansible/playbooks"))
        if playbook.endswith(".yml")
    ]
    delegate_to(
        "ansible-playbook",
        "--limit", f"{name}.home.jacquev6.net",
        *playbooks,
    )


@an.command()
@click.argument("name")
def bootstrap_ubuntu(name):
    playbooks = [
        os.path.join("bootstrap-ubuntu", playbook)
        for playbook in sorted(os.listdir("ansible/bootstrap-ubuntu"))
        if playbook.endswith(".yml")
    ] + [
        os.path.join("playbooks", playbook)
        for playbook in sorted(os.listdir("ansible/playbooks"))
        if playbook.endswith(".yml")
    ]
    delegate_to(
        "ansible-playbook",
        "--limit", f"{name}.home.jacquev6.net",
        *playbooks,
    )


@an.command()
def apply():
    playbooks = [
        os.path.join("playbooks", playbook)
        for playbook in sorted(os.listdir("ansible/playbooks"))
        if playbook.endswith(".yml")
    ]
    delegate_to(
        "ansible-playbook",
        *playbooks,
    )


@an.command()
def plan():
    playbooks = [
        os.path.join("playbooks", playbook)
        for playbook in sorted(os.listdir("ansible/playbooks"))
        if playbook.endswith(".yml")
    ]
    delegate_to(
        "ansible-playbook",
        *playbooks,
        "--check", "--diff",
    )


@cli.command(context_settings=dict(ignore_unknown_options=True, help_option_names=[]))
@click.argument("args", nargs=-1, type=click.UNPROCESSED)
def raw(args):
    delegate_to(*args)



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
    if args[0] == "terraform":
        kwds["cwd"] = "terraform"
    elif args[0] == "ansible" or args[0].startswith("ansible-"):
        args = list(args)
        args[1:1] = ["--inventory", "inventory.yml"]
        kwds["cwd"] = "ansible"
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
