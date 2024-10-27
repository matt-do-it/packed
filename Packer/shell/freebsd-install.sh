#!/bin/sh
set -e


env ASSUME_ALWAYS_YES=yes pkg install net/cloud-init
env ASSUME_ALWAYS_YES=yes pkg install curl

## Enable linux subsystem
#sysrc linux_enable="YES"

sysrc growfs_enable=YES
sysrc cloudinit_enable=YES
