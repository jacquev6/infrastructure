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


# @todo Use "kubernetes" and "helm" providers, to have to use only "terraform apply" and not "kubectl apply"
# Examples:
# - (on GKE, seems promising) https://github.com/adamcroissant/gcp-cicd-poc/blob/8eb330c1e41a9c133cc0c9c1e48ad417c1fdee24/main.tf#L26
# - (not on GKE, but good start and blog article) https://github.com/vranystepan/dok8s-terraform-example-1
# - https://github.com/dcaro/build2018/blob/609e4d39e9596d0a6ef24cda70add2bf898f3bb6/0-demo/2-kubernetes.tf#L3
# - (works around the "exec" k8s auth provider not being supported) https://github.com/niallmccullagh/terraform-eks/blob/b7c0dc29b874eacc351d90f99e3e57ac8e1ddeb6/modules/eks/providers.tf#L18
# Other examples: https://github.com/search?l=HCL&p=2&q=provider+kubernetes&type=Code
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
