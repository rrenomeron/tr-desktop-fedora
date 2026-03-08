#!/usr/bin/bash

set -eou pipefail

echo "Installing Visual Studio Code"
cat > /etc/yum.repos.d/vscode.repo << EOF
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

dnf5 -y install code

rm -rf /etc/yum.repos.d/vscode.repo

echo "Visual Studio Code installed successfully"