#!/bin/bash

# Kornyezeti valtozok beallitasat vegzo script. Hozzaadja a PATH-t es a HOME_DIR-t.
# $1: az alkalmazas fokonyvtara

if [ -z `grep -E 'PATH=.*:\/opt\/grails\/.*' /etc/environment` ]; then
	sed -e '/^PATH/s/"$/:\/opt\/grails\/grails-2.3.4\/bin"/g' -i /etc/environment
fi

ESCAPED_GRAILS_HOME="${1//\//\/}"
grep -Ev '^GRAILS_HOME=' /etc/environment > /tmp/new_environment && sed -i "1i GRAILS_HOME=$ESCAPED_GRAILS_HOME" /tmp/new_environment && mv /tmp/new_environment /etc/environment
