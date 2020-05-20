#! /bin/bash

if ifconfig enp0s20u2u3i5 >/dev/null 2>&1; then
  if ! ifconfig enp0s20u2u3i5 | grep -q RUNNING >/dev/null 2>&1; then
    /usr/bin/notify-send -u CRITICAL "Ethernet not available!"
  fi
fi
