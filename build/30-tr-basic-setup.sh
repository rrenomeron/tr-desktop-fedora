#!/usr/bin/bash

set -eou pipefail

echo "Copy TR Basic Setup (PKI, Utils, Utility Scripts)"

cp -r /ctx/system_files/tr-basic-setup/* /

update-ca-trust extract