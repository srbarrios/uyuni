#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 SUSE LLC
#
# SPDX-License-Identifier: GPL-2.0-Only

set -eu

MANAGER_COMPLETE="/root/.MANAGER_SETUP_COMPLETE"

check_current_installation() {
    if [ -e "${MANAGER_COMPLETE}" ]; then
        echo "Server appears to be already configured. Installation options may be ignored."
        exit 0
    fi
}

mark_installation_complete() {
    touch ${MANAGER_COMPLETE}
}
