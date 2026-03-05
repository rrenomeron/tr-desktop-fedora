#!/usr/bin/bash

set -eou pipefail

echo "Copy TR Basic Setup (PKI, Utils, Utility Scripts)"
cp -r /ctx/system_files/tr-pki/* /

echo "Adding TR CA to system PKI"
update-ca-trust extract
