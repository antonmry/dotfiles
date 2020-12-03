#! /bin/bash
sed -i -e 's/exec xrandr --dpi 100/exec xrandr --dpi 220/g' /home/antonmry/.config/i3/config

sed -i -e 's/Xft.dpi:       100/Xft.dpi:       220/g' /home/antonmry/.Xresources

sed -i -e 's/font = monospace 8/font = monospace 20/g' /home/antonmry/.config/dunst/dunstrc

sed -i -e 's/size: 12.0/size: 25.0/g' /home/antonmry/.config/alacritty/alacritty.yml

xrandr --output eDP-1 --auto --primary --output HDMI-1 --off
xrdb ~/.Xresources
killall i3bar
xrandr --dpi 220
i3-msg restart
killall dunst;notify-send "Changed to LVDS"
