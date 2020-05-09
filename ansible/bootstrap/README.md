Raspbian on Raspberry Pi
========================

Find MAC address(es)
--------------------

@todo Describe how to find Raspberry Pi's MAC addresses headless (https://github.com/raspberrypi/noobs/issues/501#issuecomment-394164088)
Formatting for PINN: `diskutil partitionDisk /dev/diskN 1 MBR MS-DOS PINN 15g`
@todo Describe how to add them to the Freebox using Terraform.

Download Raspbian
-----------------

    curl -O http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2020-02-14/2020-02-13-raspbian-buster-lite.zip
    unzip 2020-02-13-raspbian-buster-lite.zip

Write Raspbian to SD card (on a *macOS* computer)
-------------------------------------------------

Without the SD card:

    diskutil list

Insert the SD card, then:

    diskutil list

Note the index of the newly inserted device (/dev/diskN).

    diskutil umountDisk /dev/diskN
    sudo dd bs=10m if=2020-02-13-raspbian-buster-lite.img of=/dev/rdiskN
    cp $(find ansible/bootstrap/add-to-raspbian-boot -type f -not -name "*.tmpl") /Volumes/boot
    diskutil umountDisk /dev/diskN

Eject the SD card.

Boot for the first time and do manual bootstraping
--------------------------------------------------

Set the new node's name:

    name=whatever

(Raspbian user "pi" has initial password "raspberry")

Boot the Pi with the SD card. Then:

    ssh pi@$name.home.jacquev6.net sudo raspi-config --expand-rootfs
    ssh pi@$name.home.jacquev6.net sudo reboot now
    ssh pi@$name.home.jacquev6.net sudo raspi-config nonint do_hostname $name
    ssh pi@$name.home.jacquev6.net sudo reboot now

If you want to run repeatable experiments from an as freshly installed as possible state:

    ssh pi@$name.home.jacquev6.net sudo raspi-config nonint enable_overlayfs
    ssh pi@$name.home.jacquev6.net sudo raspi-config nonint enable_bootro
    ssh pi@$name.home.jacquev6.net sudo reboot now

Next steps are automated using Ansible:

    ./infra an apply -pb bootstrap $name


Ubuntu server on Raspberry Pi
=============================

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

Download network installer from https://ubuntu.com/download/alternative-downloads.

    diskutil umountDisk /dev/diskN
    sudo dd bs=10m if=ubuntu-19.10-mini.iso of=/dev/rdiskN

Boot on the USB flashdrive, select "Install".

Go through the install process:

  - select location, locale, etc.
  - connect to wifi
  - set hostname
  - set a temporary user named "User McUserface", with login "ubuntu" and password "ubuntu"
  - select timezone
  - partition with the "Use entire disk" option
  - no automatic updates
  - In "Software selection", choose "OpenSSH server" ans "Basic Ubuntu server"

Set the new node's name:

    name=whatever

If you want to run repeatable experiments from an as freshly installed as possible state:

    ssh -t user@$name.home.jacquev6.net sudo sed -i 's/overlayroot=.*/overlayroot=\"tmpfs\"/' /etc/overlayroot.conf
    ssh -t user@$name.home.jacquev6.net sudo reboot

Next steps are automated using Ansible:

    ./infra an bootstrap $name
