#!/bin/bash

# Fuggosegekkel rendelkezo telepitest vegzo script.
# $1: installer .deb path

# csomag telepitese
dpkg -i $1

# fuggosegek telepitese
apt-get -f -y install

# sikeres visszajelzes a puppet-nek
exit 0;
