from __future__ import absolute_import, division, print_function

import base64
import glob
import contextlib
import itertools
import os
import shutil
import subprocess32 as subprocess
import sys

sys.argv[0] = "./infra.sh"

import click


@click.group()
def cli():
    pass


@cli.command()
def init():
    subprocess.run(["terraform", "init"], check=True)


@cli.command()
def plan():
        subprocess.run(["terraform", "plan"], check=True)


@cli.command()
@click.option("--terraform-only", is_flag=True)
@click.option("--kubectl-only", is_flag=True)
def apply(terraform_only, kubectl_only):
    if not kubectl_only:
        subprocess.run(["terraform", "apply", "-auto-approve"], check=True)
    if not terraform_only:
        subprocess.run(["gcloud", "auth", "activate-service-account", "--key-file=gcp-account.json"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        subprocess.run(["gcloud", "container", "clusters", "get-credentials", "jacquev6-0002", "--zone", "europe-west1-c", "--project", "jacquev6-0001"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        for f in glob.glob("resources/gke_cluster_jacquev6_0002/workloads/*.yml"):
            print("Applying", f)
            subprocess.run(["kubectl", "apply", "-f", f], check=True)


@cli.command(context_settings=dict(
    ignore_unknown_options=True,
    help_option_names=[],
))
@click.argument("args", nargs=-1, type=click.UNPROCESSED)
def terraform(args):
    subprocess.run(["terraform"] + list(args), check=True)


@cli.command(context_settings=dict(
    ignore_unknown_options=True,
    help_option_names=[],
))
@click.argument("args", nargs=-1, type=click.UNPROCESSED)
def gcloud(args):
    subprocess.run(["gcloud", "auth", "activate-service-account", "--key-file=gcp-account.json"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    subprocess.run(["gcloud"] + list(args), check=True)


@cli.command(context_settings=dict(
    ignore_unknown_options=True,
    help_option_names=[],
))
@click.argument("args", nargs=-1, type=click.UNPROCESSED)
def kubectl(args):
    subprocess.run(["gcloud", "auth", "activate-service-account", "--key-file=gcp-account.json"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    subprocess.run(["gcloud", "container", "clusters", "get-credentials", "jacquev6-0002", "--zone", "europe-west1-c", "--project", "jacquev6-0001"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    subprocess.run(["kubectl"] + list(args), check=True)


@cli.command(context_settings=dict(
    ignore_unknown_options=True,
    help_option_names=[],
))
@click.argument("args", nargs=-1, type=click.UNPROCESSED)
def kubeseal(args):
    subprocess.run(["gcloud", "auth", "activate-service-account", "--key-file=gcp-account.json"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    subprocess.run(["gcloud", "container", "clusters", "get-credentials", "jacquev6-0002", "--zone", "europe-west1-c", "--project", "jacquev6-0001"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    subprocess.run(["kubeseal"] + list(args), check=True)


@cli.command()
def shell():
        subprocess.run(["sh"], check=True)


if __name__ == "__main__":
    cli()
