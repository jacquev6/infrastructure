from __future__ import print_function

import StringIO
import urlparse

import cairo
import DrawTurksHead

# @todo Provide a disovery API describing the parameters (name, description (localized), value range, suggested values)
# @todo Pre-compute and cache images for all combinations of suggested parameter values
# @todo (In https://jacquev6.github.io/DrawTurksHead/demo.html) Use the discovery API to populate the dropboxes.

# A bare WSGI app, because it's a very simple use-case, but we should
# use Flask or Django if it get any more complex.
def app(environ, start_response):
    # We should use python.2.7.16's max_num_fields parameter (not yet available even in Alpine 3.9)
    qs = urlparse.parse_qs(environ.get("QUERY_STRING", ""))

    def get(name, convert, default, validate=lambda x: True):
        v = qs.get(name)
        if v:
            # We don't want 500s or even 400s, we prefer to silently ignore invalid parameters
            try:
                v = convert(v[0])
            except Exception:
                print("Parameter", name, ": unable to convert", v[0], "to", convert)
                return default
            if validate(v):
                return v
            else:
                print("Parameter", name, ": invalid value", v)
                return default
        else:
            return default

    leads = get("leads", int, 3, lambda x: 1 <= x <= 32)
    bights = get("bights", int, 4, lambda x: 1 <= x <= 32)
    width = get("width", int, 640, lambda x: 1 <= x <= 2000)
    height = get("height", int, 480, lambda x: 1 <= x <= 2000)
    margin = get("margin", int, 10, lambda x: 0 <= x <= 1000)
    line_width = get("line_width", int, 25, lambda x: 1 <= x <= 500)
    inner_radius = get("inner_radius", int, 50, lambda x: 20 <= x <= 800)
    outer_radius = min(width, height) / 2 - margin

    img = cairo.ImageSurface(cairo.FORMAT_RGB24, width, height)
    ctx = cairo.Context(img)
    ctx.set_source_rgb(1, 1, 1)
    ctx.paint()
    ctx.translate(width / 2, height / 2)
    DrawTurksHead.TurksHead(leads, bights, inner_radius, outer_radius, line_width).draw(ctx)

    output = StringIO.StringIO()
    img.write_to_png(output)

    start_response('200 OK', [('Content-type', 'image/png')])
    return [output.getvalue()]
