#!/usr/bin/bash
# Setup should fail if UYUNI_HOSTNAME is not set
set -u
postconf -e "myhostname=${UYUNI_HOSTNAME}"
