# @todo Use Flask
# @todo See https://flask-restful.readthedocs.io/en/latest/
def app(environ, start_response):
    # @todo Implement :)
    start_response("200 OK", [("Content-type", "text/plain")])
    return [b"Hello\n"]
