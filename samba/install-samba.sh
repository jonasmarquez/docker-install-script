#!/usr/bin/env bash

# https://www.atlantic.net/vps-hosting/how-to-create-samba-share-on-ubuntu-20-04/

set -e

sudo apt update && sudo apt install -y samba samba-common-bin acl
sudo systemctl start smbd nmbd
sudo systemctl enable smbd nmbd

sudo smbpasswd -a $USER
sudo adduser $USER
sudo groupadd samba

sudo groupadd samba
sudo gpasswd -a $USER samba

