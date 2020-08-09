import os
import datetime
import subprocess


def rip_dvd(device: str, output_directory_path: str, now: datetime.datetime):
    os.makedirs(output_directory_path, exist_ok=True)

    try:
        isoinfo = subprocess.run(
            ["isoinfo", "-d", "-i", device],
            check=True,
            capture_output=True,
            universal_newlines=True
        ).stdout.splitlines()
        assert isoinfo[0] == "CD-ROM is in ISO 9660 format"
        assert isoinfo[2].startswith("Volume id: ")
        volume_id = isoinfo[2][11:]

        iso_path = os.path.join(output_directory_path, f"{now.strftime('%Y%m%d-%H%M%S')}-{os.path.basename(device)}-{volume_id}.iso")
        tmp_path = iso_path + ".part"

        subprocess.run(["dvdvideo-backup-image", device, tmp_path], check=True)

        os.rename(tmp_path, iso_path)
    finally:
        subprocess.run(["eject", device], check=True)
