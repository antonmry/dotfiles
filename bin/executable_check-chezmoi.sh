#! /bin/bash

if chezmoi diff | grep -q @; then
  /usr/bin/notify-send -u CRITICAL "Chezmoi changes! Run chezmoi diff!"
fi
