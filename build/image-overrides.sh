#!/usr/bin/bash

set -eoux pipefail

# Use this for build steps that are unique to this particular image
echo "Removing Fedora Flatpak remote"
# Removes the Fedora flatpak remote with extreme predjudice
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
echo "Done"

echo "Fixing Gnome 50 overview issue"
# Temp fix for Dash-To-Dock showing the overview after we tell it not to
# on GNOME 50 (bug: https://github.com/micheleg/dash-to-dock/issues/2582)
/tmp/scripts/run_module.sh 'gnome-extensions' \
    '{"type":"gnome-extensions","install":["No overview at start-up"]}'

cat - > /usr/share/glib-2.0/schemas/zz1-12-tr-default-extensions-gnome50-overview-temp-fix.gschema << GSCHEMA
[org.gnome.shell]
enabled-extensions=['appindicatorsupport@rgcjonas.gmail.com','dash-to-dock@micxgx.gmail.com','blur-my-shell@aunetx','system-monitor-next@paradoxxx.zero.gmail.com','logomenu@aryan_k','accent-directories@taiwbi.com','no-overview@fthx']

GSCHEMA
glib-compile-schemas /usr/share/glib-2.0/schemas
echo "Done"

# Install pcsc-tools for smartcard debugging purposes
dnf -y install pcsc-tools

# There seems to be an issue with swtpm setting its SELinux context correctly.
# It was fixed in https://bugzilla.redhat.com/show_bug.cgi?id=2511086, and 
# swtpm-0.10.1-4.fc44.x86_64, but I've observed that the update to 0.10.2
# broke things, despite the patch in the "good" version making it into the
# upstream source.
#
# This will overwrite the latest version of swtpm with the last known
# good working version.  Until we figure out how to fix it, remove this
# from one testing build a week and check to see if we can boot a VM
# with a software TPM.
dnf install -y swtpm-0.10.1-4.fc44.x86_64