#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 SUSE LLC
#
# SPDX-License-Identifier: GPL-2.0-Only

# Setup should fail if UYUNI_HOSTNAME is not set
set -eu
postconf -e "myhostname=${UYUNI_HOSTNAME}"
