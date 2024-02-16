# Raspberry Pis

[These SD cards](https://www.amazon.fr/gp/product/B073K14CVB) work well.

One can use [PINN](https://sourceforge.net/projects/pinn/) to find their MAC addresses: format an SD card, extract `pinn-lite.zip` on it, and add files from `os-images/raspberry-pi/add-to-pinn-lite`. Boot with the SD, wait for the LEDs to stop blinking, and then 30s more. The MAC addresses are in `info.txt` on the SD card.
