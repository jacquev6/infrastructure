#!/bin/sh

sleep 20

mount -o remount,rw /mnt

ifconfig -a >/mnt/info.txt

mount -o remount,ro /mnt
