#!/usr/bin/bash

set -eou pipefail

echo "Copy TR Basic Setup (PKI, Utils, Utility Scripts)"
cp -r /ctx/system_files/tr-basic-setup/* /

echo "Adding UI Defaults"
glib-compile-schemas /usr/share/glib-2.0/schemas
systemctl enable dconf-update.service