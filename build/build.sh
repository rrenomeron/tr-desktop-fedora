#!/usr/bin/bash

set -eou pipefail

echo "Building ${IMAGE_NAME}:${TAG}"

OSFORGE_SCRIPTS_TO_USE=(
    "flatpak-substiution-removals"
    "bluefin-parity"
    "tr-pki"
    "tr-ui"
    "google-chrome"
    "vscode"
    "cockpit"
    "virtualization"
    "docker"
)

/ctx/build/custom.sh

for scriptname in ${OSFORGE_SCRIPTS_TO_USE[@]}; do
    echo "========================================* $scriptname start *========================================"
    /ctx/oci/tr-osforge/build/$scriptname.sh
    echo "========================================* $scriptname finish *========================================"
done

echo "========================================* $IMAGE_NAME overrides start *========================================"
/ctx/build/image-overrides.sh
echo "========================================* $IMAGE_NAME overrides finish *========================================"