import os
import re
import subprocess

import ActionTree

from . import info


class Encoder:
    extension = ".mp3"

    def encode(self, wav_file_path, encoded_file_path):
        subprocess.run(
            [
                "lame",
                # "--quiet",
                "--preset", "medium",
                wav_file_path,
                encoded_file_path,
            ],
            check=True,
        )

    def load_tags(self, file_path):
        tags = {}
        for line in (
            subprocess
                .run(["id3v2", "--list", file_path], check=True, capture_output=True)
                .stdout
                .decode("utf8")
                .splitlines()
        ):
            m = re.match(r"^(T...) \(.*\): (.*)$", line)
            if m:
                tags[m.group(1)] = m.group(2)

        def int_opt(i):
            return None if i is None else int(i)

        if "TYER" in tags:
            year = int(tags["TYER"])
        else:
            year = None

        if "TRCK" in tags:
            (n, c) = tags["TRCK"].split("/")
            track_number = int(n)
            tracks_count = int(c)
        else:
            track_number = None
            tracks_count = None

        return info.Tags(
            year=year,
            album=tags.get("TALB"),
            artist=tags.get("TPE1"),
            title=tags.get("TIT2"),
            track_number=track_number,
            tracks_count=tracks_count,
        )

    def accept_tags(self, tags):
        return info.Tags(
            year=tags.year,
            album=tags.album,
            artist=tags.artist,
            title=tags.title,
            track_number=tags.track_number,
            tracks_count=tags.tracks_count,
        )

    def tag(self, path, tags):
        subprocess.run(["id3v2", "-delete", path], check=True)
        command = ["id3v2", "-2"]
        if tags.title:
            command += ["--song", tags.title]
        if tags.artist:
            command += ["--artist", tags.artist]
        if tags.year:
            command += ["--year", str(tags.year)]
        if tags.album:
            command += ["--album", tags.album]
        if tags.track_number and tags.tracks_count:
            command += ["--track", f"{tags.track_number}/{tags.tracks_count}"]
        command.append(path)
        subprocess.run(command, check=True)
