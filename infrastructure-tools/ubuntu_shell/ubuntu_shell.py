#!/usr/bin/env python3

import json
import os
import subprocess
import sys
import time


def main():
    with open(sys.argv[1]) as f:
        config = json.load(f)

    for format in ["dsa", "ecdsa", "ed25519", "rsa"]:
        key_file = f"/etc/ssh/host_keys/ssh_host_{format}_key"
        if not os.path.isfile(key_file):
            run("ssh-keygen", "-t", format, "-N", "", "-f", key_file)

    group_by_id = {group["gid"]: f"host_{group['name']}" for group in config["groups"]}

    for (gid, name) in group_by_id.items():
        run(
            "groupadd",
            "--non-unique",
            "--gid", str(gid),
            name,
        )

    for user in config["users"]:
        run(
            "useradd",
            "--shell", user.get("shell", "/bin/bash"),
            "--uid", str(user["uid"]),
            "--gid", str(user["gid"]),
            user["name"],
        )
        for gid in user.get("groups", []):
            run("adduser", user["name"], group_by_id[gid])
        with open(f"/etc/sudoers.d/{user['name']}", "w") as f:
            f.write(f"{user['name']} ALL=(ALL) NOPASSWD: ALL\n")

    for command in config.get("pre-start", []):
        subprocess.run(command, shell=True, check=True)

    os.mkdir("/run/sshd/")
    run("/usr/sbin/sshd", "-D")


def run(*args):
    subprocess.run(args, check=True)


if __name__ == "__main__":
    main()
