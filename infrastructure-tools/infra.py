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
    targets = [f"-target={resource}" for resource in resources.splitlines() if ".data." in resource or resource.startswith("data.")]
    subprocess.run(["terraform", "refresh"] + targets, check=True, cwd="terraform")


@cli.group()
def an():
    pass


@an.command()
@click.argument("groups", nargs=-1)
@click.option("--playbook", "-pb", multiple=True)
def apply(groups, playbook):
    ansible_playbook(groups, playbook)


@an.command()
@click.argument("groups", nargs=-1)
@click.option("--playbook", "-pb", multiple=True)
def plan(groups, playbook):
    ansible_playbook(groups, playbook, plan=True)


@cli.group()
def machine():
    pass


@machine.command()
@click.argument("groups", nargs=-1, required=True)
def bootstrap(groups):
    ansible_playbook(groups, ["bootstrap"])


@machine.command()
@click.argument("groups", nargs=-1)
@click.option("--playbook", "-pb", multiple=True)
@click.option("--plan", is_flag=True, default=False)
def configure(groups, playbook, plan):
    ansible_playbook(groups, playbook, plan=plan)


@machine.command()
@click.argument("groups", nargs=-1, required=True)
def freeze(groups):
    ansible_playbook(groups, ["tasks/freeze.yml"])


@machine.command()
@click.argument("groups", nargs=-1, required=True)
def unfreeze(groups):
    ansible_playbook(groups, ["tasks/unfreeze.yml"])


@machine.command()
@click.argument("groups", nargs=-1, required=True)
def reboot(groups):
    ansible_playbook(groups, ["tasks/reboot.yml"])


def ansible_playbook(groups, playbook_names, plan=False):
    command = ["ansible-playbook"]
    if plan:
        command += ["--check", "--diff"]
    if groups:
        command += ["--limit", ",".join(groups)]
    if not playbook_names:
        playbook_names = ["playbooks"]
    for playbook_name in playbook_names:
        if "/" in playbook_name:
            command.append(playbook_name)
        else:
            command += [
                os.path.join(playbook_name, playbook)
                for playbook in sorted(os.listdir(f"ansible/{playbook_name}"))
                if playbook.endswith(".yml")
            ]
    delegate_to(*command)


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
def logs():
    with open("/terraform-provider-multiverse-freebox.log") as f:
        for line in f:
            print(line.rstrip())


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
    elif args[0] == "kubectl":
        kwds["cwd"] = "kubernetes"
    try:
        exit(subprocess.run(args, **kwds).returncode)
    finally:
        if args[0] == "terraform":
            stabilize_terraform_state()


def stabilize_terraform_state():
    with open("terraform/terraform.tfstate") as f:
        state = json.load(f)
    # Keep resources sorted
    state["resources"] = sorted(state["resources"], key=lambda r: ([r.get("module", ""), r["mode"], r["type"], r["name"]]))
    # Remove changing id
    for resource in state["resources"]:
        if resource["type"] == "uptimerobot_account":
            for instance in resource["instances"]:
                instance["attributes"].pop("id", None)
    with open("terraform/terraform.tfstate", "w") as f:
        json.dump(state, f, sort_keys=True, indent=2)


if __name__ == "__main__":
    cli()
