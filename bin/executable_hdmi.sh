#! /bin/bash

case $HOSTNAME in
  (gali8)
    sed -i -e 's/exec xrandr --dpi 220/exec xrandr --dpi 100/g' /home/antonmry/.config/i3/config
    sed -i -e 's/Xft.dpi:       220/Xft.dpi:       100/g' /home/antonmry/.Xresources
    sed -i -e 's/font = Monospace 20/font = Monospace 8/g' /home/antonmry/.config/dunst/dunstrc
    sed -i -e 's/size: 25.0/size: 12.0/g' /home/antonmry/.config/alacritty/alacritty.yml
    xrandr --output HDMI-1 --auto --primary --output eDP-1 --off
    xrdb ~/.Xresources
    killall i3bar
    xrandr --dpi 100
    i3-msg restart
    killall dunst;notify-send "Changed to HDMI"
      ;;
  (gali9)
    xrandr --output HDMI-1 --auto --primary --output eDP-1 --off
    xrdb ~/.Xresources
    killall dunst;notify-send "Changed to HDMI"
      ;;
  (*)   echo "How did I get in the middle of ${HOSTNAME}?";;
esac
