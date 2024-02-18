This [infrastructure as code](https://en.wikipedia.org/wiki/Infrastructure_as_code) repository manages the infrastructure I use at various "cloud" providers and at home.

It uses [Terraform](https://www.terraform.io/) to create the infrastructure itself ([AWS](https://aws.amazon.com/), [Gandi](https://www.gandi.net/), [UptimeRobot](uptimerobot.com/)) and [Ansible](https://www.ansible.com/) to install software and configure [Docker Compose](https://docs.docker.com/compose/) environments.

# Usage

Use the scripts in the root directory.

# About raspberry Pis

[These SD cards](https://www.amazon.fr/gp/product/B073K14CVB) work well.

One can use [PINN](https://sourceforge.net/projects/pinn/) to get their MAC addresses before OS install:
format an SD card, extract `pinn-lite.zip` on it, and add files from `os-images/raspberry-pi/pinn-lite-gather-info`.
Boot with the SD, wait for the LEDs to stop blinking, and then 30s more.
The MAC addresses (and more) are in `info.txt` on the SD card.

# PC images on USB sticks as of 2024-02-18

1: lubuntu-22.04.3-desktop-amd64.iso
2: xubuntu-22.04.3-desktop-amd64.iso
3: ubuntu-22.04.3-live-server-amd64.iso
4: ubuntu-22.04.3-desktop-amd64.iso
