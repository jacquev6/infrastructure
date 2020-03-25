import os
import re
import subprocess
import textwrap

import ActionTree

from . import info


class Encoder:
    extension = ".ogg"

    def encode(self, wav_file_path, encoded_file_path):
        subprocess.run(
            [
                "oggenc",
                # "--quiet",
                wav_file_path,
                "-o", encoded_file_path,
            ],
            check=True,
        )

    def load_tags(self, file_path):
        tags = {}
        for line in (
            subprocess
                .run(["vorbiscomment", "-l", file_path], check=True, capture_output=True)
                .stdout
                .decode("utf8")
                .splitlines()
        ):
            m = re.match(r"^(.*)=(.*)$", line)
            if m:
                tags[m.group(1)] = m.group(2)

        if "year" in tags:
            year = int(tags["year"])
        else:
            year = None

        if "tracknumber" in tags:
            track_number = int(tags["tracknumber"])
        else:
            track_number = None

        return info.Tags(
            year=year,
            album=tags.get("album"),
            artist=tags.get("artist"),
            title=tags.get("title"),
            track_number=track_number,
        )

    def accept_tags(self, tags):
        return info.Tags(
            # @todo year=tags.year,
            album=tags.album,
            artist=tags.artist,
            title=tags.title,
            track_number=tags.track_number,
            # @todo Confirm we can't store tracks_count
        )

    def tag(self, path, tags):
        input = []
        if tags.title:
            input.append(f"title={tags.title}")
        if tags.artist:
            input.append(f"artist={tags.artist}")
        if tags.year:
            input.append(f"date={tags.year}")
        if tags.album:
            input.append(f"album={tags.album}")
        if tags.track_number:
            input.append(f"tracknumber={tags.track_number}")
        subprocess.run(
            ["vorbiscomment", "-w", path],
            check=True,
            input="".join(f"{line}\n" for line in input).encode("utf8"),
        )
