#!/bin/bash
if [ "${container:=unknown}" != "oci" ]; then
    echo "Skipped"
    exit 0
fi

# Prepare the cgroup mount for systemd
mount -t cgroup2 none /sys/fs/cgroup
