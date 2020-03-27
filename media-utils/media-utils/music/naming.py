import collections
import re
import string
import unicodedata

from . import info


Music = collections.namedtuple("Music", "path albums")
Album = collections.namedtuple("Album", "current_name expected_name files")
File = collections.namedtuple("File", "current_name expected_name encoder source_name current_tags expected_tags")


artists_separator = "; "  # Seriously? In file names?! What was I thinking back then? @todo Change to ", "


def name(music, encoders):
    return Music(
        path=music.path,
        albums=[name_album(a, encoders) for a in music.albums],
    )


def name_album(album, encoders):
    return Album(
        current_name=album.name,
        expected_name=normalize_name(" - ".join(expected_album_name(album))),
        files=list(name_files(album, encoders)),
    )


def expected_album_name(album):
    if album.performers:
        yield artists_separator.join(album.performers)
    else:
        if album.artists:
            yield artists_separator.join(album.artists)

    if album.order:
        yield album.order

    yield str(album.year)

    if album.performers and album.artists:
        yield artists_separator.join(album.artists)

    yield album.title

    if album.cd and album.cds:
        yield f"CD {album.cd} of {album.cds}"


def name_files(album, encoders):
    current_files = {
        (file.track_number, file.extension): file
        for file in album.files
    }

    def make_file():
        current_file = current_files.get((track_number, encoder.extension))
        current_name = current_file.name if current_file else None
        current_tags = current_file.tags if current_file else None

        return File(
            current_name=current_name,
            expected_name=normalize_name(" - ".join(expected_file_name(track_number, segment, track))) + encoder.extension,
            encoder=encoder,
            source_name=current_files[(track_number, ".wav")].name,
            current_tags=current_tags,
            expected_tags=encoder.accept_tags(expected_tags(track_number, album, segment, track, encoder.extension)),
        )

    for encoder in encoders:
        # @todo Encode Karajan as .mp3 as well
        if encoder.extension == ".mp3" and album.name.startswith("Herbert von Karajan"):
            continue
        track_number = 1

        segment = None
        for track in album.tracks:
            yield make_file()
            track_number += 1

        for segment in album.segments:
            for track in segment.tracks:
                yield make_file()
                track_number += 1


def expected_file_name(track_number, segment, track):
    yield f"{track_number:02}"

    if segment and segment.title:
        yield segment.title

    yield track.title

    if track.artists:
        yield artists_separator.join(track.artists)

    if track.performers:
        yield artists_separator.join(track.performers)


# @todo Remove extension parameter: homogenize behavior for all encoders
def expected_tags(track_number, album, segment, track, extension):
    album_title = album.title
    if extension == ".mp3" and  album.cd and album.cds:
        album_title += f" (CD {album.cd} of {album.cds})"

    artist = artists_separator.join(
        []
        + (segment.artists if segment and segment.artists else album.artists)
        + track.artists
        + (segment.performers if segment and segment.performers else album.performers)
        + track.performers
    )

    if extension == ".mp3":
        artist = artist or None

    track_title = track.title if segment is None or segment.title is None else f"{segment.title} - {track.title}"

    if track_title == "1+1=3" and extension == ".ogg":
        track_title = None

    return info.Tags(
        year=album.year,
        album=album_title,
        artist=artist,
        title=track_title,
        track_number=track_number,
        tracks_count=len(album.tracks) + sum(len(segment.tracks) for segment in album.segments),
    )


def normalize_name(name):
    name = unicodedata.normalize("NFKD", name)
    name = name.replace("/", "-")
    name = "".join(c for c in name if c in set("-_.![](),;&' %s%s" % (string.ascii_letters, string.digits)))
    name = re.sub("\\s+", " ", name)
    name = name.strip()
    name = name.lstrip("-")
    name = name.strip(".")
    return name
