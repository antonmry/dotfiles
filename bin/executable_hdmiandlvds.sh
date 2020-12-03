#! /bin/bash
sed -i -e 's/exec xrandr --dpi 200/exec xrandr --dpi 100/g' /home/antonmry/.config/i3/config

sed -i -e 's/Xft.dpi:       220/Xft.dpi:       100/g' /home/antonmry/.Xresources

xrandr --output HDMI-1 --auto --primary --output eDP-1 --auto
xrdb ~/.Xresources
i3-msg restart
