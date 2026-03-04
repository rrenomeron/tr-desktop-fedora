#!/usr/bin/bash

# Disable the MCE service if it won't work on our processor.
# Known issue with MCE: https://access.redhat.com/solutions/158503


if systemctl is-enabled mcelog.service > /dev/null; then
    if grep flags /proc/cpuinfo | grep hypervisor > /dev/null; then
        if ! systemctl status --no-pager mcelog.service > /dev/null; then
            CPU_VENDOR=$(grep vendor_id /proc/cpuinfo | head -1 | cut -d ":" -f 2 | awk '{$1=$1;print}')
            CPU_FAMILY=$(grep "cpu family" /proc/cpuinfo | head -1| cut -d ":" -f 2 | awk '{$1=$1;print}')
            if [ "$CPU_VENDOR" == 'AuthenticAMD' ]; then
                if [ $CPU_FAMILY -gt 15 ]; then
                    echo "Disabling mcelog.service because it does not work on this machine"
                    systemctl disable --now mcelog.service
                fi 
            fi   
        fi
    fi
fi
