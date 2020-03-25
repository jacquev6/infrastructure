from . import info

class Encoder:
    extension = ".wav"

    def load_tags(self, file_path):
        return info.Tags()

    def accept_tags(self, tags):
        return info.Tags()
