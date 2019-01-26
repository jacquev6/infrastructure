#!/usr/bin/env python3

import os
import contextlib
import shutil
import subprocess
import sys
import base64

sys.argv[0] = "./infra.sh"

import click

@click.group()
def cli():
    pass


class Secrets:
    # See https://bjornjohansen.no/encrypt-file-using-ssh-key

    # PASSWORD_ENC generated once with
    # openssl rand 32 | openssl rsautl -encrypt -oaep -pubin -inkey <(ssh-keygen -e -f ~/.ssh/id_rsa.pub -m PKCS8) | base64 --wrap=0
    PASSWORD_ENC = "XwH9JDk0QBH3WO09r7g+/nzU+ypn51/bpconrGDTq94ydSu1D7dTxD7fZwfSTf+iVdd6OmKqXsPWQNH1EGxRbNf8QV+jBGVPTG56WgHAix3gTOpKnn9gMvKvpPu3AEeE9Tyzdl7s1SxeIwlNkLQR/LjllCDKmyJIuacalk/B5qwo5mgCpzArG1UPQEYaEGekL+Gd0p0CejtZlX7YX8VKTC41WN3DqRQ/HUA9dFqWlv3iM1uwQOLWc42cL3xNH/yTUan1IWJWzgyNsvsbB+YeigF7dnG942jSUSvqDYS8MDRIo13KVLLz3A9FI8bcyyC7uRJ/T3HxFBl1ru7nLOGP2Q=="

    PASSWORD = b"pass:" + subprocess.run(
        ["openssl", "rsautl", "-decrypt", "-oaep", "-inkey", "/ssh/id_rsa"],
        stdout=subprocess.PIPE,
        input=base64.b64decode(PASSWORD_ENC),
        check=True,
    ).stdout

    def __init__(self):
        with open(".gitignore") as f:
            self.__secrets = []
            record = False
            for line in f:
                if record:
                    self.__secrets.append(line.strip().lstrip("/"))
                if line.strip() == "# Secrets":
                    record = True

    @contextlib.contextmanager
    def __call__(self):
        self.__decrypt()
        try:
            yield
        finally:
            self.__encrypt()

    def __decrypt(self):
        for secret in self.__secrets:
            if not os.path.isfile(secret):
                print("Decrypting", secret + ".enc")
                self.__crypt("-d", "-in", secret + ".enc", "-out", secret)

    def __encrypt(self):
        for secret in self.__secrets:
            with open(secret) as f:
                content = f.read()
            if not (os.path.exists(secret + ".enc") and self.__crypt("-d", "-in", secret + ".enc").decode('latin-1') == content):
                print("Encrypting", secret)
                self.__crypt("-in", secret, "-out", secret + ".enc")

    def __crypt(self, *args):
        return subprocess.run(
            ["openssl", "aes-256-cbc", "-md", "sha256", "-pass", self.PASSWORD] + list(args),
            stdout=subprocess.PIPE,
            check=True,
        ).stdout


secrets = Secrets()


@cli.command()
def init():
    with secrets():
        subprocess.run(["terraform", "init"], check=True)


@cli.command(name="secrets")
def secrets_():
    with secrets():
        pass


@cli.command()
def plan():
    with secrets():
        subprocess.run(["terraform", "plan"], check=True)


@cli.command()
def apply():
    with secrets():
        subprocess.run(["terraform", "apply", "-auto-approve"], check=True)


@cli.command(context_settings=dict(
    ignore_unknown_options=True,
    help_option_names=[],
))
@click.argument('args', nargs=-1, type=click.UNPROCESSED)
def terraform(args):
    with secrets():
        subprocess.run(["terraform"] + list(args), check=True)



if __name__ == "__main__":
    cli()
