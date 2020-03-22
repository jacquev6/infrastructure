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

    def __init__(self, *, app_id, app_token, debug, requestor=requests):
        self.__debug = debug
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
        self.__debug(f"FREEBOX: {method} {path}\n")
        self.__debug(f"FREEBOX: {data}\n")
        r = getattr(self.__requestor, method)(
            f"{self.base_url}/{path}",
            **data,
            headers=self.__headers,
        ).json()
        self.__debug(f"FREEBOX: {r}\n")
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
    with freebox() as f:
        print(json.dumps(f.get(path), sort_keys=True, indent=2))


class StandardResource:
    def __init__(self, freebox, base_path):
        self.__freebox = freebox
        self.__base_path = base_path

    def create(self, id, payload):
        return self._return(self.__freebox.post(
            f"{self.__base_path}/",
            self._create(payload),
        ))

    def read(self, id, payload):
        return self._return(self.__freebox.get(
            f"{self.__base_path}/{id}",
        ))

    def update(self, id, payload):
        return self._return(self.__freebox.put(
            f"{self.__base_path}/{id}",
            self._update(payload)
        ))

    def delete(self, id, payload):
        self.__freebox.delete(f"{self.__base_path}/{id}")
        return {}


class StaticDhcpLease(StandardResource):
    def __init__(self, freebox):
        super().__init__(freebox, "dhcp/static_lease")

    def _create(self, payload):
        return {"mac": payload["mac"], "ip": payload["ip"]}

    def _return(self, r):
        return {"id": r["id"], "mac": r["mac"], "ip": r["ip"]}

    def _update(self, payload):
        return {"ip": payload["ip"]}


class PortForwarding(StandardResource):
    # @todo Handle reboots of Freebox: ids are reset to 1, 2, 3...

    def __init__(self, freebox):
        super().__init__(freebox, "fw/redir")

    def _create(self, payload):
        return {
            "enabled": True,
            "lan_port": payload["port"],
            "wan_port_end": payload["port"],
            "wan_port_start": payload["port"],
            "lan_ip": payload["ip"],
            "ip_proto": "tcp",
            "src_ip": "0.0.0.0",
        }

    def _return(self, r):
        return {"id": r["id"], "port": r["lan_port"], "ip": r["lan_ip"]}

    def _update(self, payload):
        return {
            "lan_port": payload["port"],
            "wan_port_end": payload["port"],
            "wan_port_start": payload["port"],
            "lan_ip": payload["ip"],
        }


class HostNaming:
    # @todo Handle update of MAC address: this changes the ID

    def __init__(self, freebox):
        self.__freebox = freebox

    def create(self, id, payload):
        return self.update(payload["mac"], payload)

    def read(self, id, payload):
        return self._return(self.__freebox.get(
            f"lan/browser/pub/ether-{id}",
        ))

    def update(self, id, payload):
        return self._return(self.__freebox.put(
            f"lan/browser/pub/ether-{id}",
            dict(
                primary_name=payload["name"],
            )
        ))

    def _return(self, r):
        return {"id": r["id"][6:], "name": r["primary_name"]}

    def delete(self, id, payload):
        return {}


resources = {
    "static_dhcp_lease": StaticDhcpLease,
    "port_forwarding": PortForwarding,
    "host_naming": HostNaming,
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
                with freebox(debug.write) as f:
                    ret = {k: str(v) for (k, v) in command(resources[payload["kind"]](f), id, payload).items()}
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


@contextlib.contextmanager
def freebox(debug=lambda _: None):
    with open("freebox_app_token.secret.txt") as f:
        app_token = f.read().strip()
    with Freebox(app_id="infrastructure", app_token=app_token, debug=debug) as freebox:
        yield freebox


@cli.command()
@crud_command
def create(kind, id, payload):
    return kind.create(id, payload)


@cli.command()
@crud_command
def read(kind, id, payload):
    return kind.read(id, payload)


@cli.command()
@crud_command
def update(kind, id, payload):
    return kind.update(id, payload)


@cli.command()
@crud_command
def delete(kind, id, payload):
    return kind.delete(id, payload)


if __name__ == "__main__":
    cli()
