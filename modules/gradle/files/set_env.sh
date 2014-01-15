#!/bin/bash

# Kornyezeti valtozok beallitasat vegzo script. Hozzaadja a PATH-t es a HOME_DIR-t.
# $1: az alkalmazas fokonyvtara

update-alternatives --install "/usr/bin/gradle" "gradle" "$1/bin/gradle" 1

ESCAPED_HOME="${1//\//\/}"
grep -Ev '^GRADLE_HOME=' /etc/environment > /tmp/new_environment && sed -i "1i GRADLE_HOME=\"$ESCAPED_HOME\"" /tmp/new_environment && mv /tmp/new_environment /etc/environment
