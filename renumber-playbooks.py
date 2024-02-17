#!/usr/bin/env python3

import os


def main():
    current_playbook_file_names = os.listdir("configuration/playbooks")
    for current_name, new_name in renumber(current_playbook_file_names):
        print(f"Renaming {current_name} to {new_name}")
        os.rename(f"configuration/playbooks/{current_name}", f"configuration/playbooks/{new_name}")


def renumber(names):
    assert all("/" not in name for name in names)

    filtered_names = [
        name for name in names
        if name.split("-")[0].isdigit() and name.endswith(".yml")
    ]
    sorted_names = sorted(filtered_names, key=lambda name: int(name.split("-")[0]))

    index = 10
    for name in sorted_names:
        base_name = name.split("-", 1)[1]
        expected_name = f"{index:04d}-{base_name}"
        if name != expected_name:
            yield (name, expected_name)
        index += 10


assert list(renumber(["0010-a.yml", "0020-b.yml"])) == []
assert list(renumber(["0005-a.yml", "0010-b.yml"])) == [("0005-a.yml", "0010-a.yml"), ("0010-b.yml", "0020-b.yml")]
assert list(renumber(["0010-a.yml", "0015-b.yml", "0020-c.yml"])) == [("0015-b.yml", "0020-b.yml"), ("0020-c.yml", "0030-c.yml")]
assert list(renumber(["0010-a.yml", "0015-b.yml"])) == [("0015-b.yml", "0020-b.yml")]


if __name__ == "__main__":
    main()
