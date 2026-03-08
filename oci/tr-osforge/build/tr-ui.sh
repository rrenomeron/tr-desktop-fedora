#!/usr/bin/bash

set -eou pipefail

echo "Copy system files for TR UI Fixes"
cp -r /ctx/oci/tr-osforge/system_files/tr-ui-fixes/* /

echo "Installing Gnome Extensions"
/tmp/scripts/run_module.sh 'gnome-extensions' \
    '{"type":"gnome-extensions","install":["system-monitor-next","Accent Icons","Weather or Not","DeskChanger"]}'

echo "Adding Fonts"
/tmp/scripts/run_module.sh 'fonts' \
  '{ "type": "fonts", "fonts" : {"google-fonts": [ "Roboto", "Roboto Condensed", "Lato", "Lora", "Montserrat" ], "url-fonts": [ { "name": "intel-one-mono-fonts", "url": "https://github.com/intel/intel-one-mono/releases/download/V1.4.0/otf.zip" }, { "name": "gentium-7", "url": "https://software.sil.org/downloads/r/gentium/Gentium-7.000.zip" }, { "name": "charis-7", "url": "https://software.sil.org/downloads/r/charis/Charis-7.000.zip" } ] }}'

echo "Installing System76 Wallpapers"
curl -L https://system76.com/content/downloads/System76-Wallpapers.zip > /tmp/System76-Wallpapers.zip
mkdir /usr/share/backgrounds/system76
unzip /tmp/System76-Wallpapers.zip -d /usr/share/backgrounds/system76

echo "Installing Framework Wallpapers"
curl -L https://downloads.frame.work/assets/framework-laptop12-wallpaper-pack.zip > /tmp/framework-wallpapers.zip
mkdir /usr/share/backgrounds/framework
unzip /tmp/framework-wallpapers.zip -d /usr/share/backgrounds/framework

echo "Adding UI Defaults"
glib-compile-schemas /usr/share/glib-2.0/schemas
systemctl enable dconf-update.service
