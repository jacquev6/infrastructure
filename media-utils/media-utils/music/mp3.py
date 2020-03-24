import os
import re
import subprocess

import ActionTree
import ActionTree.stock


class Encoder:
    extension = ".mp3"

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

        return [
            "--song", tags.get("TIT2"),
            "--artist", tags.get("TPE1"),
            "--year", tags.get("TYER"),
            "--album", tags.get("TALB"),
            "--track", tags.get("TRCK"),
        ]

    def compute_tags(self, album, track_number):
        return [
            "--song", album.tracks[track_number-1],
            "--artist", album.artist,
            "--year", album.year,
            "--album", album.title,
            "--track", f"{track_number}/{len(album.tracks)}",
        ]

    class make_tag_action(ActionTree.Action):
        def __init__(self, label, dependencies, path, tags):
            super().__init__(label, dependencies=dependencies)
            self.__path = path
            self.__tags = tags

        def do_execute(self, dependency_statuses):
            subprocess.run(
                ["id3v2", "-2"] + self.__tags + [self.__path],
                check=True,
            )

    class make_encode_action(ActionTree.Action):
        def __init__(self, label, wav_file_path, mp3_file_path):
            super().__init__(label)
            self.__wav_file_path = wav_file_path
            self.__mp3_file_path = mp3_file_path

        def do_execute(self, dependency_statuses):
            tmp_file_path = self.__mp3_file_path + ".tmp"
            subprocess.run(
                ["lame", "--quiet", "--preset", "medium", self.__wav_file_path, tmp_file_path],
                check=True,
            )
            os.rename(tmp_file_path, self.__mp3_file_path)
