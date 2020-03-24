import os
import subprocess

import ActionTree


class Encoder:
    extension = ".ogg"

    def load_tags(self, file_path):
        return sorted(
            subprocess
                .run(["vorbiscomment", "-l", file_path], check=True, capture_output=True)
                .stdout
                .decode("utf8")
                .splitlines()
        )

    def compute_tags(self, album, track_number):
        return [
            f"album={album.title}",
            f"artist={album.artist}",
            f"date={album.year}",
            f"title={album.tracks[track_number-1]}",
            f"tracknumber={track_number}",
        ]

    class make_tag_action(ActionTree.Action):
        def __init__(self, label, dependencies, path, tags):
            super().__init__(label, dependencies=dependencies)
            self.__path = path
            self.__tags = tags

        def do_execute(self, dependency_statuses):
            subprocess.run(
                ["vorbiscomment", "-w", self.__path],
                check=True,
                input="".join(f"{tag}\n" for tag in self.__tags).encode("utf8"),
            )

    class make_encode_action(ActionTree.Action):
        def __init__(self, label, wav_file_path, ogg_file_path):
            super().__init__(label)
            self.__wav_file_path = wav_file_path
            self.__ogg_file_path = ogg_file_path

        def do_execute(self, dependency_statuses):
            tmp_file_path = self.__ogg_file_path + ".tmp"
            subprocess.run(
                ["oggenc", "--quiet", self.__wav_file_path, "-o", tmp_file_path],
                check=True,
            )
            os.rename(tmp_file_path, self.__ogg_file_path)
