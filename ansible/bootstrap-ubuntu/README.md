Boot on the USB flashdrive, select "Install".

Go through the install process:

  - select location, locale, etc.
  - connect to wifi
  - set hostname
  - set a temporary user named "User McUserface", with login "user" and password "password"
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

    ./infra an bootstrap-ubuntu $name
