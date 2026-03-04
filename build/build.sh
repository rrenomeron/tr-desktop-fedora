#!/usr/bin/bash

set -eou pipefail

###############################################################################
# Main Build Script
###############################################################################
# This script follows the @ublue-os/bluefin pattern for build scripts.
# It uses set -eoux pipefail for strict error handling and debugging.
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

# /ctx/build/10-custom.sh
# /ctx/build/20-bluefin-common.sh
# /ctx/build/30-tr-basic-setup.sh
# /ctx/build/41-google-chrome.sh

for scriptname in /ctx/build/[0-9][0-9]-*.sh; do
    echo "::group:: Running $(basename $scriptname)"
    $scriptname
    echo "::endgroup::"
done