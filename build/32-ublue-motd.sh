#!/usr/bin/bash

set -eou pipefail

echo "Setting up non-Bluefin ublue-motd"
cp -r /ctx/system_files/ublue-motd/* /