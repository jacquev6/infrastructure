from __future__ import print_function

import json
import StringIO

import cairo
import DrawTurksHead
import flask


# @todo Pre-compute and cache images for all combinations of suggested parameter values

app = flask.Flask(__name__)


class Parameter:
    def __init__(self, name, description, min_value, default_value, max_value, suggested_values):
        self.name = name
        self.description = description
        self.min_value = min_value
        self.default_value = default_value
        self.max_value = max_value
        self.suggested_values = sorted(set(suggested_values) | set([default_value]))


parameters = [
    Parameter("leads", "Number of leads", 1, 3, 32, list(range(1, 11))),
    Parameter("bights", "Number of bights", 1, 4, 32, list(range(1, 11))),
    Parameter("line_width", "Line width (pixels)", 1, 25, 500, [12, 18, 25, 35, 50, 70]),
    Parameter("inner_radius", "Inner radius (pixels)", 20, 50, 800, [50, 75, 100, 150]),
    Parameter("width", "Width (pixels)", 1, 640, 2000, []),
    Parameter("height", "Height (pixels)", 1, 480, 2000, []),
    Parameter("margin", "Margin (pixels)", 0, 10, 1000, []),
]


@app.route("/")
def index():
    params = {parameter.name: parameter for parameter in parameters}

    def get(name):
        parameter = params[name]
        value = flask.request.args.get(name)

        # Silently ignore invalid parameters
        try:
            value = int(value)
        except (ValueError, TypeError):
            pass
        else:
            if parameter.min_value <= value <= parameter.max_value:
                return value

        return parameter.default_value

    leads = get("leads")
    bights = get("bights")
    width = get("width")
    height = get("height")
    margin = get("margin")
    line_width = get("line_width")
    inner_radius = get("inner_radius")

    outer_radius = min(width, height) / 2 - margin

    img = cairo.ImageSurface(cairo.FORMAT_RGB24, width, height)
    ctx = cairo.Context(img)
    ctx.set_source_rgb(1, 1, 1)
    ctx.paint()
    ctx.translate(width / 2, height / 2)
    DrawTurksHead.TurksHead(leads, bights, inner_radius, outer_radius, line_width).draw(ctx)

    output = StringIO.StringIO()
    img.write_to_png(output)

    return flask.Response(output.getvalue(), mimetype="image/png")


@app.route("/parameters")
def params():
    return flask.Response(
        json.dumps(
            [
                dict(
                    name=parameter.name,
                    description=parameter.description,
                    min_value=parameter.min_value,
                    max_value=parameter.max_value,
                    default_value=parameter.default_value,
                    suggested_values=parameter.suggested_values,
                )
                for parameter in parameters
            ],
            separators=(",", ":"),
        ),
        headers={"Access-Control-Allow-Origin":"*"},
        mimetype="application/json",
    )
