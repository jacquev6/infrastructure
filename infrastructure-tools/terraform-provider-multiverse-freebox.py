#!/usr/bin/env python3

import contextlib
import functools
import hmac
import json
import sys
import time
import traceback

import click
import requests


class Freebox(contextlib.AbstractContextManager):
    # https://dev.freebox.fr/sdk/os/ documents API v4, even if FreeboxOS uses v6
    base_url = "http://192.168.1.254/api/v4"

    @classmethod
    def get_app_token(cls, *, app_id, app_name, app_version, device_name, requestor=requests):
        # https://dev.freebox.fr/sdk/os/login/#
        r = requestor.post(
            f"{cls.base_url}/login/authorize/",
            data=json.dumps({
                "app_id": app_id,
                "app_name": app_name,
                "app_version": app_version,
                "device_name": device_name,
            }),
        ).json()
        assert r["success"], r
        app_token = r["result"]["app_token"]
        track_id = r["result"]["track_id"]
        status = "pending"
        while status == "pending":
            time.sleep(1)
            r = requestor.get(f"{cls.base_url}/login/authorize/{track_id}").json()
            assert r["success"], r
            status = r["result"]["status"]
        if status == "granted":
            return app_token
        else:
            raise Exception(f"Access refused or not granted in time ({status})")

    def __init__(self, *, app_id, app_token, requestor=requests):
        self.__requestor = requestor
        # We don't handle session token invalidation because this script is short-lived.
        # If this class is used in a more general context, __request should detect when
        # session token is refused and call __login again.
        self.__login(app_id, app_token)

    def __login(self, app_id, app_token):
        self.__headers = {}
        challenge = self.__request("get", "login")["challenge"]
        data = {
            "app_id": app_id,
            "password": hmac.new(app_token.encode(), challenge.encode(), "sha1").hexdigest(),
        }
        session_token = self.__request("post", "login/session/", data)["session_token"]
        self.__headers = {"X-Fbx-App-Auth": session_token}

    def __exit__(self, exc_type, exc_value, traceback):
        self.__request("post", "login/logout/")

    def get(self, path):
        return self.__request("get", path)

    def put(self, path, data):
        return self.__request("put", path, data)

    def post(self, path, data):
        return self.__request("post", path, data)

    def delete(self, path):
        return self.__request("delete", path)

    def __request(self, method, path, data=None):
        if data is None:
            data = dict()
        else:
            data = dict(data=json.dumps(data))
        r = getattr(self.__requestor, method)(
            f"{self.base_url}/{path}",
            **data,
            headers=self.__headers,
        ).json()
        assert r["success"], r
        return r.get("result")


@click.group()
def cli():
    pass


@cli.command()
def login():
    print("Please confirm on Freebox", flush=True)
    app_token = Freebox.get_app_token(
        app_id="infrastructure",
        app_name="Infrastructure",
        app_version="1",
        device_name="Terraform",
    )
    with open("freebox_app_token.secret.txt", "w") as f:
        f.write(f"{app_token}\n")
    print("Please fix permissions for newly registered app: add 'Modification des réglages de la Freebox'")


@cli.command()
@click.argument("path")
def get(path):
    with open("freebox_app_token.secret.txt") as f:
        app_token = f.read().strip()
    with Freebox(app_id="infrastructure", app_token=app_token) as freebox:
        print(json.dumps(freebox.get(path), sort_keys=True, indent=2))


# @to_maybe_do Use classes and objects?
resource_kinds = {
    "static_dhcp_lease": dict(
        base_path="dhcp/static_lease",
        create=lambda payload: {"mac": payload["mac"], "ip": payload["ip"]},
        update=lambda payload: {"ip": payload["ip"]},
        ret=lambda r: {"id": r["id"], "mac": r["mac"], "ip": r["ip"]}
    ),
    "port_forwarding": dict(
        base_path="fw/redir",
        create=lambda payload: {
            "enabled": True,
            "lan_port": payload["port"],
            "wan_port_end": payload["port"],
            "wan_port_start": payload["port"],
            "lan_ip": payload["ip"],
            "ip_proto": "tcp",
            "src_ip": "0.0.0.0",
        },
        update=lambda payload: {
            "lan_port": payload["port"],
            "wan_port_end": payload["port"],
            "wan_port_start": payload["port"],
            "lan_ip": payload["ip"],
        },
        ret=lambda r: {"id": r["id"], "port": r["lan_port"], "ip": r["lan_ip"]}
    ),
}


def crud_command(command):
    @functools.wraps(command)
    def wrapper():
        with open("/terraform-provider-multiverse-freebox.log", "a") as debug:
            try:
                debug.write(f"COMMAND: {command.__name__}\n")
                raw = sys.stdin.read()
                debug.write(f"RAW: {raw}\n")
                data = json.loads(raw)
                debug.write(f"DATA: {data}\n")
                id = data.get("ID")
                debug.write(f"ID: {id}\n")
                payload = json.loads(data["Payload"])
                debug.write(f"PAYLOAD: {payload}\n")
                kind = resource_kinds[payload["kind"]]
                with open("freebox_app_token.secret.txt") as f:
                    app_token = f.read().strip()
                with Freebox(app_id="infrastructure", app_token=app_token) as freebox:
                    ret = {k: str(v) for (k, v) in command(kind, id, payload, freebox).items()}
                debug.write(f"RET: {ret}\n")
            except:
                debug.write(f"ERROR: {traceback.format_exc()}\n")
                raise
            else:
                debug.write("OK\n")
            finally:
                debug.write("\n")
        print(json.dumps(ret))
    return wrapper


@cli.command()
@crud_command
def create(kind, id, payload, freebox):
    return kind["ret"](freebox.post(f"{kind['base_path']}/", kind["create"](payload)))


@cli.command()
@crud_command
def read(kind, id, payload, freebox):
    return kind["ret"](freebox.get(f"{kind['base_path']}/{id}"))


@cli.command()
@crud_command
def update(kind, id, payload, freebox):
    return kind["ret"](freebox.put(f"{kind['base_path']}/{id}", kind["update"](payload)))


@cli.command()
@crud_command
def delete(kind, id, payload, freebox):
    freebox.delete(f"{kind['base_path']}/{id}")
    return {}


if __name__ == "__main__":
    cli()
