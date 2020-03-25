import itertools
import os.path
import re
import unicodedata
import string

import ActionTree
import ActionTree.stock


def make_action(music):
    return regroup_actions(make_tidy_music_actions(music)) or ActionTree.stock.NullAction()


def make_tidy_music_actions(music):
    for album in music.albums:
        yield make_tidy_album_action(music, album)


def make_tidy_album_action(music, album):
    file_actions = list(make_tidy_files_actions(music, album))

    if album.current_name == album.expected_name:
        return regroup_actions(file_actions)
    else:
        return RenameAction(
            music.path,
            album.current_name,
            album.expected_name,
            dependencies=file_actions,
        )


def make_tidy_files_actions(music, album):
    # Encode
    rename_depencencies = {}
    for file in album.files:
        if file.current_name is None:
            wav_file_path = os.path.join(music.path, album.current_name, file.source_name)
            encoded_file_path = os.path.join(music.path, album.current_name, file.expected_name)
            encode_action = EncodeAction(
                file.encoder,
                wav_file_path,
                encoded_file_path,
            )
            rename_depencencies.setdefault(wav_file_path, []).append(encode_action)
            yield TagAction(
                file.encoder,
                encoded_file_path,
                file.current_tags,
                file.expected_tags,
                dependencies=[encode_action],
            )

    # Tag
    for file in album.files:
        if file.current_tags and file.expected_tags and str(file.current_tags) != str(file.expected_tags):
            path = os.path.join(music.path, album.current_name, file.current_name)
            tag_action = TagAction(
                file.encoder,
                path,
                file.current_tags,
                file.expected_tags,
            )
            rename_depencencies.setdefault(path, []).append(tag_action)
            yield tag_action

    # Rename
    for file in album.files:
        if file.current_name and file.expected_name and file.current_name != file.expected_name:
            path = os.path.join(music.path, album.current_name, file.current_name)
            yield RenameAction(
                os.path.join(music.path, album.current_name),
                file.current_name,
                file.expected_name,
                dependencies=rename_depencencies.get(path, []),
            )
 
    # Delete
    for file in album.files:
        if file.expected_name is None:
            # @todo Delete file?
            pass


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


class TagAction(ActionTree.Action):
    def __init__(self, encoder, path, old_tags, tags, *, dependencies=[]):
        if old_tags:
            label = f"Retag '{path}': {old_tags} -> {tags}"
        else:
            label = f"Tag '{path}': {tags}"
        super().__init__(label, dependencies=dependencies)
        self.__encoder = encoder
        self.__path = path
        self.__tags = tags

    def do_execute(self, dependency_statuses):
        self.__encoder.tag(self.__path, self.__tags)


class EncodeAction(ActionTree.Action):
    def __init__(self, encoder, wav_file_path, encoded_file_path):
        super().__init__(f"Encode '{wav_file_path}' to '{os.path.basename(encoded_file_path)}'")
        self.__encoder = encoder
        self.__wav_file_path = wav_file_path
        self.__encoded_file_path = encoded_file_path

    def do_execute(self, dependency_statuses):
        tmp_file_path = self.__encoded_file_path + ".tmp"
        self.__encoder.encode(self.__wav_file_path, tmp_file_path)
        os.rename(tmp_file_path, self.__encoded_file_path)
