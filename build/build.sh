#!/usr/bin/bash

set -eou pipefail

echo "Building ${IMAGE_NAME}:${TAG}"

OSFORGE_SCRIPTS_TO_USE=(
    "15-flatpak-substiution-removals"
    "20-bluefin-parity"
    "30-tr-pki"
    "31-tr-ui-fixes"
    "41-google-chrome"
    "42-vscode"
    "43-cockpit"
    "44-virtualization"
    "45-docker"
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