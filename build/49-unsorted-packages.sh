#!/usr/bin/bash

set -eou pipefail

dnf5 -y install \
    socat \
    intel-one-mono-fonts \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-blur-my-shell \
    gnome-tweaks