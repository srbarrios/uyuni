#!/usr/bin/bash
if [ -n "${TZ}" ]; then
    if [ ! -e "/usr/share/zoneinfo/${TZ}" ]; then
      echo "Wrong timezone set: '${TZ}'"
      exit 1
    fi
    rm -f /etc/localtime
    ln -s "/usr/share/zoneinfo/${TZ}" /etc/localtime
fi
