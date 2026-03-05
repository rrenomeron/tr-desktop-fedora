#!/usr/bin/bash

set -eou pipefail

echo "Copy TR Basic Setup (PKI, Utils, Utility Scripts)"
cp -r /ctx/system_files/tr-ui-fixes/* /

echo "Installing Gnome Extensions"
/tmp/scripts/run_module.sh 'gnome-extensions' \
    '{"type":"gnome-extensions","install":["system-monitor-next","Accent Icons","Weather or Not","DeskChanger"]}'

echo "Adding UI Defaults"
glib-compile-schemas /usr/share/glib-2.0/schemas
systemctl enable dconf-update.service
