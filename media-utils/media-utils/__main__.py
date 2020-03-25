#!/usr/bin/env python3

import os

import ActionTree
import click

from . import music

# @todo Proper logging


@click.group()
def main():
    pass


@main.group(name="music")
def music_():
    pass


@music_.command()
@click.argument("path")
@click.option("--dry-run", is_flag=True)
def tidy(path, dry_run):
    encoders = [music.wav.Encoder(), music.ogg.Encoder(), music.mp3.Encoder()]
    info = music.info.load(path, encoders)
    named = music.naming.name(info, encoders)
    tidy = music.tidy.make_action(named)
    if dry_run:
        for a in tidy.get_possible_execution_order():
            if a.label is not None:
                print(a.label)
        graph = ActionTree.DependencyGraph(tidy)
        graph.write_to_png(os.path.join(path, "tidy.png"))
    else:
        ActionTree.execute(tidy, hooks=Hooks())


class Hooks(ActionTree.Hooks):
    def action_started(self, time, action):
        if action.label is not None:
            print(action.label)


if __name__ == "__main__":
    main()
