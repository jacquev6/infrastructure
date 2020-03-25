import json
import os.path
import re


class Music:
    def __init__(self, *, path, albums):
        assert isinstance(path, str) and path
        self.path = path
        assert isinstance(albums, list) and all(isinstance(a, Album) for a in albums)
        self.albums = albums


class Album:
    def __init__(self, *, name, year, title, artists, performers, cd, cds, order, segments, tracks, files):
        assert isinstance(name, str) and name
        self.name = name
        assert isinstance(year, int)
        self.year = year
        assert isinstance(title, str)  # @todo and title
        self.title = title
        assert isinstance(artists, list) and all(isinstance(a, str) and a for a in artists)
        self.artists = artists
        assert isinstance(performers, list) and all(isinstance(p, str) and p for p in performers)
        self.performers = performers
        assert cd is None or isinstance(cd, int)
        assert cds is None or isinstance(cds, int)
        self.cd = cd
        self.cds = cds
        assert order is None or isinstance(order, str) and order
        self.order = order
        assert isinstance(segments, list) and all(isinstance(s, Segment) for s in segments)
        self.segments = segments
        assert isinstance(tracks, list) and all(isinstance(t, Track) for t in tracks)
        self.tracks = tracks
        assert isinstance(files, list) and all(isinstance(f, File) for f in files)
        self.files = files


class Segment:
    def __init__(self, *, title, artists, performers, tracks):
        assert title is None or isinstance(title, str) and title
        self.title = title
        assert isinstance(artists, list) and all(isinstance(a, str) and a for a in artists)
        self.artists = artists
        assert isinstance(performers, list) and all(isinstance(p, str) and p for p in performers)
        self.performers = performers
        assert isinstance(tracks, list) and all(isinstance(t, Track) for t in tracks)
        self.tracks = tracks


class Track:
    def __init__(self, *, title, artists, performers):
        assert isinstance(title, str) and title
        self.title = title
        self.artists = artists
        self.performers = performers


class File:
    def __init__(self, *, name, track_number, extension, tags):
        assert isinstance(name, str) and name
        self.name = name
        assert isinstance(track_number, int) and track_number
        self.track_number = track_number
        assert isinstance(extension, str) and extension
        self.extension = extension
        assert isinstance(tags, Tags)
        self.tags = tags


class Tags:
    def __init__(
        self,
        *,
        year=None,
        album=None,
        artist=None,
        title=None,
        track_number=None,
        tracks_count=None,
    ):
        assert year is None or isinstance(year, int), year
        self.year = year
        assert album is None or isinstance(album, str), album
        self.album = album
        assert artist is None or isinstance(artist, str), artist
        self.artist = artist
        assert title is None or isinstance(title, str), title
        self.title = title
        assert track_number is None or isinstance(track_number, int), track_number
        self.track_number = track_number
        assert tracks_count is None or isinstance(tracks_count, int), tracks_count
        self.tracks_count = tracks_count

    def __str__(self):
        return f"'{self.year}' '{self.album}' '{self.artist}' '{self.title}' '{self.track_number}' '{self.tracks_count}'"


def load(music_path, encoders):
    encoders = {encoder.extension: encoder for encoder in encoders}
    return Music(
        path=music_path,
        albums=list(load_albums(music_path, encoders)),
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
        **load_album_info(**info),
        files=list(load_files(album_path, encoders)),
    )


def load_album_info(
    *,
    year,
    title,
    artist=None,
    artists=None,
    performer=None,
    performers=None,
    cd=None,
    cds=None,
    order=None,
    segments=None,
    tracks=None,
):
    assert isinstance(year, str) and year, f"album year: {year}"
    year = int(year)

    # @todo Forbid empty title (requires fixing data)
    assert isinstance(title, str), f"album title: {title}"

    if artists is None:
        artists = []
    else:
        assert isinstance(artists, list), f"album artists: {artists}"
    artists = list(artists)
    if artist:
        artists.append(artist)
    assert all(isinstance(a, str) and a for a in artists), f"album artists: {artists}"

    if performers is None:
        performers = []
    else:
        assert isinstance(performers, list), f"album performers: {performers}"
    performers = list(performers)
    if performer:
        performers.append(performer)
    assert all(isinstance(p, str) and p for p in performers), f"album performers: {performers}"

    assert cd is None or isinstance(cd, int), f"album cd: {cd}"

    assert cds is None or isinstance(cds, int), f"album cds: {cds}"

    assert order is None or isinstance(order, str) and order, f"album order: {order}"

    assert (segments is None) != (tracks is None), f"album tracks: {tracks}, segments: {segments}"

    if segments is None:
        segments = []
    segments = [load_segment_info(**segment) for segment in segments]

    if tracks is None:
        tracks = []
    tracks = [
        load_track_info(title=track) if isinstance(track, str) else load_track_info(**track)
        for track in tracks
    ]

    return dict(
        year=year,
        title=title,
        artists=artists,
        performers=performers,
        cd=cd,
        cds=cds,
        order=order,
        segments=segments,
        tracks=tracks,
    )


def load_track_info(
    *,
    title,
    artist=None,
    artists=None,
    performer=None,
    performers=None,
):
    assert isinstance(title, str) and title, f"track title: {title}"

    if artists is None:
        artists = []
    else:
        assert isinstance(artists, list), f"track artists: {artists}"
    artists = list(artists)
    if artist:
        artists.append(artist)
    assert all(isinstance(a, str) and a for a in artists), f"track artists: {artists}"

    if performers is None:
        performers = []
    else:
        assert isinstance(performers, list), f"track performers: {performers}"
    performers = list(performers)
    if performer:
        performers.append(performer)
    assert all(isinstance(p, str) and p for p in performers), f"track performers: {performers}"

    return Track(
        title=title,
        artists=artists,
        performers=performers,
    )


def load_segment_info(
    *,
    title,
    artist=None,
    artists=None,
    performer=None,
    performers=None,
    tracks,
):
    assert isinstance(title, str) and title, f"segment title: {title}"

    if artists is None:
        artists = []
    else:
        assert isinstance(artists, list), f"segment artists: {artists}"
    artists = list(artists)
    if artist:
        artists.append(artist)
    assert all(isinstance(a, str) and a for a in artists), f"segment artists: {artists}"

    if performers is None:
        performers = []
    else:
        assert isinstance(performers, list), f"segment performers: {performers}"
    performers = list(performers)
    if performer:
        performers.append(performer)
    assert all(isinstance(p, str) and p for p in performers), f"segment performers: {performers}"

    if tracks == [""]:
        # Segment with a single untitled track: transfer segment title to track
        tracks = [load_track_info(title=title)]
        title = None
    else:
        tracks = [
            load_track_info(title=track) if isinstance(track, str) else load_track_info(**track)
            for track in tracks
        ]

    return Segment(
        title=title,
        artists=artists,
        performers=performers,
        tracks=tracks,
    )


def load_files(album_path, encoders):
    for file_name in os.listdir(album_path):
        extension = os.path.splitext(file_name)[1]
        encoder = encoders.get(extension)
        if encoder:
            m = re.match(r"^(\d\d) -.*$", file_name) or re.match(r"^track(\d\d)\.cdda\..*$", file_name)
            assert m, f"file_name: {file_name}"
            track_number = int(m.group(1))

            yield File(
                name=file_name,
                track_number=track_number,
                extension=extension,
                tags=encoder.load_tags(os.path.join(album_path, file_name)),
            )
