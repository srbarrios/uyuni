#!/bin/bash
set -e

RESTART_MARKER="/var/run/uyuni-restart-pending"
if [ -f "${RESTART_MARKER}" ]; then
    echo "Restart pending – reporting unhealthy"
    exit 1
fi

/usr/bin/systemctl is-active multi-user.target
salt-call --local --no-color status.ping_master localhost |grep -q True
curl --noproxy localhost --fail http://localhost/rhn/manager/login
