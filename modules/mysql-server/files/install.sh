#!/bin/bash

# Fuggosegekkel rendelkezo telepitest vegzo script.
# $1: installer .deb file path
# $2: alkalmazas home konyvtara

# csomag telepitese
dpkg -i $1

# futtathato allomanyok bekotese
update-alternatives --install "/usr/bin/mysql" "mysql" "/opt/mysql/server-5.5/bin/mysql" 1
update-alternatives --install "/usr/bin/mysqld_safe" "mysqld_safe" "/opt/mysql/server-5.5/bin/mysqld_safe" 1

# atadjuk a jogokat a mysql usernek
cd $2
chown -R mysql .
chgrp -R mysql .

# alap beallitasok telepitese
scripts/mysql_install_db --user=mysql --basedir=$2 --datadir=$2/data

# sikeres visszajelzes a puppet-nek
exit 0;
