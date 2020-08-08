import time

import click


@click.group()
def main():
    pass


@main.command()
@click.argument("devices", nargs=-1)
def chain_rip(devices):
    print("Chain ripping from the following devices:", " ".join(devices), flush=True)
    while True:
        time.sleep(10)


if __name__ == "__main__":
    main()
