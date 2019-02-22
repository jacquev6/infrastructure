#!/usr/bin/env python3

import glob
import os
import subprocess
import sys
import yaml

sys.argv[0] = "./infra"

import click


@click.group()
def cli():
    pass


@cli.command()
def init():
    subprocess.run(["terraform", "init"], check=True)


@cli.command()
def plan():
    increment_chart_versions()
    subprocess.run(["terraform", "plan", "-refresh=false"], check=True)


@cli.command()
def apply():
    increment_chart_versions()
    subprocess.run(["terraform", "apply", "-refresh=false", "-auto-approve"], check=True)


@cli.command(context_settings=dict(ignore_unknown_options=True, help_option_names=[]))
@click.argument("args", nargs=-1, type=click.UNPROCESSED)
def terraform(args):
    increment_chart_versions()
    subprocess.run(["terraform"] + list(args), check=True)


def increment_chart_versions():
    for chart_file in glob.glob("charts/*/Chart.yaml"):
        chart_directory = os.path.dirname(chart_file)
        if subprocess.run(["git", "status", "--porcelain", chart_directory], check=True, stdout=subprocess.PIPE).stdout:
            # Additionaly, we could check the currently applied version in terraform.state and increment only if it matches the current chart version
            with open(chart_file) as f:
                chart = yaml.load(f)
            chart["version"] += 1
            with open(chart_file, "w") as f:
                yaml.dump(chart, f, default_flow_style=False)


@cli.command(context_settings=dict(ignore_unknown_options=True, help_option_names=[]))
@click.argument("cluster")
@click.argument("args", nargs=-1, type=click.UNPROCESSED)
def gcloud(cluster, args):
    init_gcloud(cluster)
    subprocess.run(["gcloud"] + list(args), check=True)


@cli.command(context_settings=dict(ignore_unknown_options=True, help_option_names=[]))
@click.argument("cluster")
@click.argument("args", nargs=-1, type=click.UNPROCESSED)
def kubectl(cluster, args):
    init_gcloud(cluster)
    subprocess.run(["kubectl"] + list(args), check=True)


@cli.command(context_settings=dict(ignore_unknown_options=True, help_option_names=[]))
@click.argument("cluster")
@click.argument("args", nargs=-1, type=click.UNPROCESSED)
def kubeseal(cluster, args):
    init_gcloud(cluster)
    subprocess.run(["kubeseal"] + list(args), check=True)


@cli.command(context_settings=dict(ignore_unknown_options=True, help_option_names=[]))
@click.argument("cluster")
@click.argument("args", nargs=-1, type=click.UNPROCESSED)
def helm(cluster, args):
    init_gcloud(cluster)
    subprocess.run(["helm"] + list(args), check=True)


def init_gcloud(cluster):
    subprocess.run(["gcloud", "auth", "activate-service-account", "--key-file=provider.google.secret.json"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    subprocess.run(["gcloud", "container", "clusters", "get-credentials", cluster, "--zone", "europe-west1-c", "--project", "jacquev6-0001"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)


@cli.command()
def shell():
    subprocess.run(["sh"], check=True)


@cli.command()
@click.argument("ip")
@click.argument("name")
def check_certificate(ip, name):
    subprocess.run(["openssl", "s_client", "-showcerts", "-servername", name, "-connect", ip + ":443"], check=True, input="")


if __name__ == "__main__":
    cli()
