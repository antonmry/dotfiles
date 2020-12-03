#! /bin/bash

case $HOSTNAME in
  (gali8)
        killall chrome
        killall alacritty
        killall slack
        google-chrome &
        i3-msg 'workspace 2:Terminal; exec tmux.sh' &
        idea &
        slack &
        xinput --set-button-map 13 1 1 3
      ;;
  (gali9)
        killall chrome
        killall thunderbird
        killall alacritty
        killall slack
        killall minetime
        killall autokey-gtk
        killall teams
        /usr/bin/autokey-gtk &
        /usr/bin/teams &
        google-chrome &
        /opt/MineTime/minetime &
        thunderbird &
        i3-msg 'workspace 2:Terminal; exec tmux.sh' &
        idea &
        slack &
        /usr/bin/pavucontrol &
      ;;
  (*)   echo "How did I get in the middle of ${HOSTNAME}?";;
esac

