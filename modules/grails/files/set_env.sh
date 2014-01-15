#!/bin/bash

# Kornyezeti valtozok beallitasat vegzo script. Hozzaadja a PATH-t es a HOME_DIR-t.
# $1: az alkalmazas fokonyvtara

update-alternatives --install "/usr/bin/grails" "grails" "$1/bin/grails" 1
update-alternatives --install "/usr/bin/grails-debug" "grails-debug" "$1/bin/grails-debug" 1
update-alternatives --install "/usr/bin/startGrails" "startGrails" "$1/bin/startGrails" 1

ESCAPED_HOME="${1//\//\/}"
grep -Ev '^GRAILS_HOME=' /etc/environment > /tmp/new_environment && sed -i "1i GRAILS_HOME=\"$ESCAPED_HOME\"" /tmp/new_environment && mv /tmp/new_environment /etc/environment
