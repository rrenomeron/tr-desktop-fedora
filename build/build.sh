#!/usr/bin/bash

set -eou pipefail

echo "Building ${IMAGE_NAME}:${TAG}"

for scriptname in /ctx/build/[0-9][0-9]-*.sh; do
    echo "::group:: Running $(basename $scriptname)"
    $scriptname
    echo "::endgroup::"
done