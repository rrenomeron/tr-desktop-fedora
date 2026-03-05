#!/usr/bin/bash

set -eou pipefail

# Notes: The Gnome Extensions and fonts will move out of this script
# once we get Bluebuild modules working

dnf5 -y install \
    gnome-tweaks \
    glow \
    gum \
    intel-one-mono-fonts \
    socat

# This adds the version of flatpak that can do preinstalls
# Remove when Fedora 44 is a thing
  dnf -y copr enable ublue-os/flatpak-test
  dnf -y copr disable ublue-os/flatpak-test
  dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak flatpak
  dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-libs flatpak-libs
  dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-session-helper flatpak-session-helper
  dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test install flatpak-debuginfo flatpak-libs-debuginfo flatpak-session-helper-debuginfo