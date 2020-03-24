import os.path
import json
import collections


Music = collections.namedtuple("Music", "path albums")
Album = collections.namedtuple("Album", "name artist year title tracks files")
File = collections.namedtuple("File", "name tags")


def load(music_path, encoders):
    encoders = {encoder.extension: encoder for encoder in encoders}
    return Music(
        music_path,
        list(load_albums(music_path, encoders)),
    )


def load_albums(music_path, encoders):
    for album_name in os.listdir(music_path):
        album_path = os.path.join(music_path, album_name)
        if os.path.isdir(album_path):
            yield load_album(album_path, encoders)


def load_album(album_path, encoders):
    with open(os.path.join(album_path, "info.json")) as f:
        info = json.load(f)["text_info"]
    return Album(
        name=os.path.basename(album_path),
        artist=info["artist"],
        year=info["year"],
        title=info["title"],
        tracks=info["tracks"],
        files=list(load_files(album_path, encoders)),
    )


def load_files(album_path, encoders):
    for file_name in os.listdir(album_path):
        encoder = encoders.get(os.path.splitext(file_name)[1])
        if encoder:
            yield File(
                name=file_name,
                tags=encoder.load_tags(os.path.join(album_path, file_name)),
            )
