#!/usr/bin/bash

set -eou pipefail

echo "Building ${IMAGE_NAME}:${TAG}"

# Add the features from tr-osforge that you want to incude in your image.
# The scripts can be found in reusable_scripts/build; include the name without the ".sh"
# suffix, e.g. putting "google-chrome" in this array will run "google-chrome.sh" in your build.
# The scripts are run in order.
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

if command -v dnf5; then
    export DNF_CMD=dnf5
else 
    export DNF_CMD=dnf
fi

# echo "=========================================================================================="
# echo " STARTING $IMAGE_NAME OVERRIDES (PREBUILD)"
# echo "=========================================================================================="
# /ctx/build/image-overrides-prebuild.sh
# echo "=========================================================================================="
# echo " $IMAGE_NAME OVERRIDES (PREBUILD) FINISHED "
# echo "=========================================================================================="


for scriptname in "${OSFORGE_SCRIPTS_TO_USE[@]}"; do
    echo "=========================================================================================="
    echo " STARTING $scriptname "
    echo "=========================================================================================="
    /ctx/oci/tr-osforge/build/"$scriptname".sh
    echo "=========================================================================================="
    echo " $scriptname FINISHED"
    echo "=========================================================================================="
done

echo "=========================================================================================="
echo " STARTING $IMAGE_NAME OVERRIDES "
echo "=========================================================================================="
/ctx/build/image-overrides.sh
echo "=========================================================================================="
echo " $IMAGE_NAME OVERRIDES FINISHED "
echo "=========================================================================================="

echo "=========================================================================================="
echo " STARTING CUSTOM FLATPAK/BREW/UJUST CONFIGURATION" 
echo "=========================================================================================="
/ctx/build/custom.sh
echo "=========================================================================================="
echo " CUSTOM FLATPAK/BREW/UJUST CONFIGURATION FINISHED -- BUILD COMPLETE "
echo "=========================================================================================="