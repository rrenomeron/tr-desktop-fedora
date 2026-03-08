#!/usr/bin/bash

set -oeu pipefail

# These are not present in the latest silverblue
# dnf5 -y remove \
# 	baobab \
# 	gnome-calculator \
# 	gnome-characters \
# 	gnome-clocks \
# 	gnome-font-viewer \
# 	gnome-text-editor \
# 	papers \
# 	snapshot \
# 	loupe \
# 	PackageKit  \
# 	PackageKit-command-not-found \
# 	gnome-extensions-app

dnf -y remove \
	gnome-disk-utility \
	gnome-software