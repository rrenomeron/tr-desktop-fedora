#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

###############################################################################
# IMPORTANT CONVENTIONS (from @ublue-os/bluefin):
# - Always clean up temporary repository files after installation
# - Use dnf5 exclusively (never dnf or yum)
# - Always use -y flag for non-interactive operations
# - Remove repo files to keep the image clean (repos don't work at runtime)
###############################################################################

### Install Google Chrome from Official Repository
echo "Installing Google Chrome..."

# Add Google Chrome RPM repository
cat > /etc/yum.repos.d/google-chrome.repo << 'EOF'
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF

mkdir -p /var/opt/
mkdir -p /usr/lib/opt/google
ln -s /usr/lib/opt/google /var/opt/google
cat > /usr/lib/tmpfiles.d/99-google-chrome-in-opt.conf << EOF
L+?  "/var/opt/google"  -  -  -  -  /usr/lib/opt/google
EOF

# Install Chrome
dnf5 install -y google-chrome-stable

# Clean up repo file (required - repos don't work at runtime in bootc images)
rm -f /etc/yum.repos.d/google-chrome.repo

echo "Google Chrome installed successfully"