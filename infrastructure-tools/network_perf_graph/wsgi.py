import json
import os
import signal
import stat
import subprocess
import time


hosts = [
    "idee",
    "doorman",
    "nas2",
]

os.chmod("/root/.ssh/id_rsa", stat.S_IRUSR)

# @todo Evaluate https://python-rq.org/ to put iperf3 tests in the background
# (Pay attention to server port and bandwith collisions. Only one test should happen at a time)
# @todo Evaluate Flask
# @todo Consider making a Vue.js frontend and an API (REST or GraphQL)
# @todo Consider using WebSockets to keep frontend up-to-date when new iperf3 tests are done

def app(environ, start_response):
    start_response("200 OK", [("Content-type", "text/plain")])
    for server in hosts:
        for client in hosts:
            if client != server:
                yield f"{client} -> {server}: ".encode("utf-8")
                with subprocess.Popen(
                    ["ssh", f"jacquev6@{server}.home.jacquev6.net", "iperf3", "--server", "--one-off"],
                    stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                ):
                    time.sleep(1)
                    perf = json.loads(subprocess.run(
                        [
                            "ssh", f"jacquev6@{client}.home.jacquev6.net",
                            "iperf3", "--client", f"{server}.home.jacquev6.net",
                            "--time", "1", "--json",
                        ],
                        check=True,
                        universal_newlines=True,
                        stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                    ).stdout)
                sent = int(perf["end"]["sum_sent"]["bits_per_second"]/1000)/1000
                received = int(perf["end"]["sum_received"]["bits_per_second"]/1000)/1000
                yield f"sent {sent}Mb/s, received {received}Mb/s\n".encode("utf-8")
