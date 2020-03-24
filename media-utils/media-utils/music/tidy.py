import itertools
import os.path
import re
import unicodedata
import string

import ActionTree
import ActionTree.stock


def make_tidy_action(music, encoders):
    encoders = {encoder.extension: encoder for encoder in encoders}
    return regroup_actions(make_tidy_music_actions(music, encoders)) or ActionTree.stock.NullAction()


def make_tidy_music_actions(music, encoders):
    for album in music.albums:
        yield make_tidy_album_action(music, album, encoders)


def make_tidy_album_action(music, album, encoders):
    rename_track_actions = filter_actions(make_tidy_track_actions(music, album, encoders))

    expected_album_name = compute_album_name(album)
    actual_album_path = os.path.join(music.path, album.name)
    if album.name == expected_album_name:
        return regroup_actions(rename_track_actions)
    else:
        return RenameAction(
            music.path,
            album.name,
            expected_album_name,
            dependencies=rename_track_actions,
        )


def make_tidy_track_actions(music, album, encoders):
    files_by_extension = group_files_by_extension(album.files)

    wav_files = files_by_extension[".wav"]
    track_numbers = set(range(1, 1 + len(album.tracks)))
    assert set(wav_files.keys()) == track_numbers

    encode_actions = {}

    for (extension, encoder) in encoders.items():
        if extension != ".wav":
            encoded_files = files_by_extension.get(extension, {})
            for track_number in track_numbers:
                wav_file_name = wav_files[track_number].name
                wav_file_path = os.path.join(music.path, album.name, wav_file_name)
                if track_number not in encoded_files:
                    encoded_file_name = compute_track_name(album, track_number, extension)
                    encoded_file_path = os.path.join(music.path, album.name, encoded_file_name)
                    encode_action = encoder.make_encode_action(
                        f"Encode '{wav_file_path}' to '{encoded_file_name}'",
                        wav_file_path,
                        encoded_file_path,
                    )
                    encode_actions.setdefault(wav_file_name, []).append(encode_action)
                    yield encoder.make_tag_action(
                        f"Tag '{encoded_file_path}'",
                        [encode_action],
                        encoded_file_path,
                        encoder.compute_tags(album, track_number),
                    )

    for (extension, files) in files_by_extension.items():
        encoder = encoders[extension]
        for (track_number, file) in files.items():
            dependencies = []

            expected_tags = encoder.compute_tags(album, track_number)
            if file.tags != expected_tags:
                dependencies.append(encoder.make_tag_action(
                    f"Retag '{os.path.join(music.path, album.name, file.name)}'",
                    [],
                    os.path.join(music.path, album.name, file.name),
                    expected_tags,
                ))

            expected_track_name = compute_track_name(album, track_number, extension)
            if file.name == expected_track_name:
                yield regroup_actions(dependencies)
            else:
                yield RenameAction(
                    os.path.join(music.path, album.name),
                    file.name,
                    expected_track_name,
                    dependencies=dependencies + encode_actions.get(file.name, []),
                )


def group_files_by_extension(files):
    def ext(file):
        return os.path.splitext(file.name)[1]

    return {
        extension: {get_track_number(file.name): file for file in track_names}
        for (extension, track_names) in itertools.groupby(sorted(files, key=ext), key=ext)
    }


def get_track_number(file_name):
    m = re.match(r"^(\d\d) -.*$", file_name) or re.match(r"^track(\d\d)\.cdda\..*$", file_name)
    assert m, file_name
    return int(m.group(1))



def regroup_actions(actions):
    actions = filter_actions(actions)
    if len(actions) == 0:
        return None
    elif len(actions) == 1:
        return actions[0]
    else:
        return ActionTree.stock.NullAction(dependencies=actions)


def filter_actions(actions):
    return list(filter(None, actions))


class RenameAction(ActionTree.Action):
    def __init__(self, where, src, dst, *, dependencies=[]):
        super().__init__(f"Rename '{where}/{src}' to '{dst}'", dependencies=dependencies)
        self.__where = where
        self.__src = src
        self.__dst = dst

    def do_execute(self, dependency_statuses):
        os.rename(os.path.join(self.__where, self.__src), os.path.join(self.__where, self.__dst))


class SubprocessRun(ActionTree.Action):
    def __init__(self, label, *args, dependencies=[], **kwds):
        super().__init__(label, dependencies=dependencies)
        self.__args = args
        self.__kwds = kwds

    def do_execute(self, dependency_statuses):
        subprocess.run(*self.__args, **self.__kwds)


def compute_album_name(album):
    return normalize_name(f"{album.artist} - {album.year} - {album.title}")


def compute_track_name(album, track_number, extension):
    return normalize_name(f"{track_number:02} - {album.tracks[track_number-1]}") + extension


def normalize_name(name):
    name = unicodedata.normalize("NFKD", name)
    name = name.replace("/", "-")
    name = "".join(c for c in name if c in set("-_.![](),;&' %s%s" % (string.ascii_letters, string.digits)))
    name = re.sub("\\s+", " ", name)
    name = name.strip()
    name = name.lstrip("-")
    name = name.strip(".")
    return name
