Raspberry Pis
=============

About micro-SD cards
--------------------

[These ones](https://www.amazon.fr/gp/product/B073K14CVB) work great.

Identify the card (before and after inserting it):

    diskutil list

Below, the card is named `/dev/diskN` or `/dev/rdiskN`; change `N` accordingly.

Unmout it (before any block-level operation):

    diskutil umountDisk /dev/diskN

Find MAC address(es)
--------------------

- Download PINN from https://sourceforge.net/projects/pinn/
- Format a SD card with `diskutil partitionDisk /dev/diskN 1 MBR MS-DOS PINN 500m` (change diskN to actual name)
- Extract the archive onto the SD card
- Add files from `add-to-pinn`
- Boot the PI with the SD, give it time (wait for the LEDs to stop blinking, and then 30s more)
- The MAC address is in `info.txt` on the SD card
- The SD card is reusable as-is

Ubuntu server
-------------

Download "Ubuntu Server 64 bits" from https://ubuntu.com/download/raspberry-pi.

Extract image on SD card:

    sudo dd if=ubuntu-20.04-preinstalled-server-arm64+raspi.img of=/dev/rdiskN bs=32m
    cp $(find ansible/bootstrap/add-to-raspberry-pi-ubuntu-system-boot -type f -not -name "*.tmpl") /Volumes/system-boot
    diskutil umountDisk /dev/diskN

Eject the SD card.

Boot, wait 5 minutes. Reboot. Tada, the PI is on the network.

Set host name:

    name=<<<name>>>
    ssh ubuntu@$name.home.jacquev6.net
    # password is "ubuntu"
    # Then:
    hostnamectl set-hostname <<<name>>>
    sudo reboot

Next steps are automated using Ansible:

    ./infra an apply -pb bootstrap $name

Ubuntu (minimal) on PC
======================

Download network installer from http://archive.ubuntu.com/ubuntu/dists/focal/main/installer-amd64/current/legacy-images/netboot/mini.iso.

    diskutil umountDisk /dev/diskN
    sudo dd bs=10m if=ubuntu-20.04-lts-mini.iso of=/dev/rdiskN

Boot from the USB flashdrive, select "Install".

Go through the install process:

  - select location, locale, etc.
  - connect to wifi
  - set hostname
  - set a temporary user named "User McUserface", with login "ubuntu" and password "ubuntu"
  - select timezone
  - partition with the "Use entire disk" option
  - no automatic updates
  - In "Software selection", choose "OpenSSH server" and "Basic Ubuntu server"

Set the new node's name:

    name=whatever

If you want to run repeatable experiments from an as freshly installed as possible state:

    ssh -t ubuntu@$name.home.jacquev6.net sudo sed -i 's/overlayroot=.*/overlayroot=\"tmpfs\"/' /etc/overlayroot.conf
    ssh -t ubuntu@$name.home.jacquev6.net sudo reboot

Next steps are automated using Ansible:

    ./infra bootstrap $name
