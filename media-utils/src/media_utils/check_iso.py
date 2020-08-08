import subprocess
import os.path
import shutil
import sys


def check_iso(iso_path, ok_dir_path, error_dir_path):
    os.makedirs(ok_dir_path, exist_ok=True)
    os.makedirs(error_dir_path, exist_ok=True)

    m4v_path = f"{iso_path[:-4]}.m4v"

    cmd = [
        "HandBrakeCLI",
        "--input", iso_path,
        "--output", m4v_path,
        "--preset-import-file", os.path.join(os.path.dirname(__file__), "check_iso.handbrake.json"), "--preset", "Check",
        "--main-feature",
    ]
    try:
        p = subprocess.run(cmd, capture_output=True, universal_newlines=True, check=True)
        if "ERROR" in p.stdout or "ERROR" in p.stderr:
            raise subprocess.CalledProcessError(0, cmd, p.stdout, p.stderr)
    except subprocess.CalledProcessError as e:
        print(e.stdout, flush=True)
        print(e.stderr, file=sys.stderr)
        shutil.move(iso_path, error_dir_path)
        shutil.move(m4v_path, error_dir_path)
        raise
    else:
        print(p.stdout, flush=True)
        print(p.stderr, file=sys.stderr)
        shutil.move(iso_path, ok_dir_path)
        shutil.move(m4v_path, ok_dir_path)
