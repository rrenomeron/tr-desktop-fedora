#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Main Build Script
###############################################################################
# This script follows the @ublue-os/bluefin pattern for build scripts.
# It uses set -eoux pipefail for strict error handling and debugging.
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
# source /ctx/build/copr-helpers.sh

echo "Copy Bluefin and Shared Config from Common"

# Copy just files from @projectbluefin/common (includes 00-entry.just which imports 60-custom.just)
mkdir -p /usr/share/ublue-os/just/
shopt -s nullglob
cp -r /ctx/oci/common/bluefin/usr/share/ublue-os/just/* /usr/share/ublue-os/just/
cp -r /ctx/oci/common/shared/* /
shopt -u nullglob

echo "Installing Gnome Extensions from Bluefin"
/tmp/scripts/run_module.sh 'gnome-extensions' \
    '{"type":"gnome-extensions","install":["AppIndicator and KStatusNotifierItem Support","Dash to Dock","Blur my Shell","Logo Menu"]}'


# This is not technically in the common OCI container (it's in bluefin itself),
# But we'll include it here for now
cat > /usr/lib/systemd/system/flatpak-nuke-fedora.service << SERVICE_UNIT
[Unit]
Description=Remove Fedora flatpak repositories
Before=flatpak-preinstall.service
Before=flatpak-system-helper.service
# Make sure we run before the Fedora service if it exists
Before=flatpak-add-fedora-repos.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/flatpak remote-delete --system fedora
ExecStart=/usr/bin/flatpak remote-delete --system fedora-testing
# Make sure even if flatpak-add-fedora-repos.service  exists, it
# won't run.
ExecStart=/usr/bin/touch /var/lib/flatpak/.fedora-initialized
# Flatpak will fail if the remote doesn't exist, but we don't mind
SuccessExitStatus=1

[Install]
WantedBy=multi-user.target
SERVICE_UNIT

systemctl enable flatpak-nuke-fedora.service

