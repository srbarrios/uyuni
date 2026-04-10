#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 SUSE LLC
#
# SPDX-License-Identifier: GPL-2.0-Only
set -e

# Update postfix hostname only when hostname is provided
[ -n "$UYUNI_HOSTNAME" ] && postconf -e "myhostname=${UYUNI_HOSTNAME}"
