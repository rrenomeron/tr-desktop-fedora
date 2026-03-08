#!/usr/bin/bash

set -eou pipefail

echo "Installing Virtualization packages"
# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

dnf5 -y --setopt=install_weak_deps=False install \
    libvirt \
    libvirt-nss \
    cockpit-machines

echo "Installing various libvirt fixes" 
copr_install_isolated ublue-os/packages ublue-os-libvirt-workarounds

# Copied from Bluefin
cat > /usr/bin/bluefin-dx-groups << "DX_GROUPS_SCRIPT"
#!/usr/bin/env bash

# SCRIPT VERSION
GROUP_SETUP_VER=1
GROUP_SETUP_VER_FILE="/etc/ublue/dx-groups"
GROUP_SETUP_VER_RAN=$(cat "$GROUP_SETUP_VER_FILE")

# make the directory if it doesn't exist
mkdir -p /etc/ublue

# Run script if updated
if [[ -f $GROUP_SETUP_VER_FILE && "$GROUP_SETUP_VER" = "$GROUP_SETUP_VER_RAN" ]]; then
  echo "Group setup has already run. Exiting..."
  exit 0
fi

# Function to append a group entry to /etc/group
append_group() {
  local group_name="$1"
  if ! grep -q "^$group_name:" /etc/group; then
    echo "Appending $group_name to /etc/group"
    grep "^$group_name:" /usr/lib/group | tee -a /etc/group >/dev/null
  fi
}

# Setup Groups
append_group docker
append_group incus-admin
append_group libvirt

wheelarray=($(getent group wheel | cut -d ":" -f 4 | tr ',' '\n'))
for user in $wheelarray; do
  usermod -aG docker $user
  usermod -aG incus-admin $user
  usermod -aG libvirt $user
done

# Prevent future executions
echo "Writing state file"
echo "$GROUP_SETUP_VER" >"$GROUP_SETUP_VER_FILE"
DX_GROUPS_SCRIPT

cat > /usr/lib/systemd/system/bluefin-dx-groups.service << "SYSTEMD_UNIT"
[Unit]
Description=Add wheel members to docker,and incus-admin groups

[Service]
Type=oneshot
ExecStart=/usr/bin/bluefin-dx-groups
Restart=on-failure
RestartSec=30
StartLimitInterval=0

[Install]
WantedBy=default.target
SYSTEMD_UNIT

systemctl enable bluefin-dx-groups.service

echo "done"