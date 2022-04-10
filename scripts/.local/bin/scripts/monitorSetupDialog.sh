#!/bin/bash
#
# a simple dmenu monitor setup script
#
###
intern="eDP1"
extern="HDMI2"

# allows to set a specific output using a keybinding
if [ $1 = "acer" ]; then 
    xrandr --output "$intern" --off --output "$extern" --mode 1920x1080
    nitrogen --restore
    # echo 'acer'
    exit
elif [ $1 = "eizo" ]; then
    xrandr --output "$intern" --off --output "$extern" --mode 2560x1440
    nitrogen --restore
    # echo 'eizo'
    exit
fi

# allows to set a specific output using dmenu
echo 'choose in dmenu'
choice=$(default-terminal -e | echo -e 'mac\neizo(mono)\nacer(mono)\neizo(dual)\nacer(dual)' | dmenu -p 'monitor setup: ')

case "$choice" in
    "mac") xrandr --output "$extern" --off --output "$intern" --auto & ;;
    "eizo(mono)") xrandr --output "$intern" --off --output "$extern" --mode 2560x1440 & ;;
    "acer(mono)") xrandr --output "$intern" --off --output "$extern" --mode 1920x1080 & ;;
    "eizo(dual)") xrandr --output "$extern" --set audio force-dvi --mode 2560x1440 && xrandr --output "$intern" --auto --output "$extern" --primary --above "$intern" & ;;
    "acer(dual)") xrandr --output "$extern" --set audio force-dvi --mode 1920x1080 && xrandr --output "$intern" --auto --output "$extern" --primary --above "$intern" & ;;
    #"duplicate") xrandr --output "$extern" --set audio force-dvi --mode 1920x1080 && xrandr --output "$intern" --auto --output "$extern" --same-as "$intern" ;;
    *) notify-send "Multi Monitor" "Unknown Operation" ;;
esac

# restore wallpaper to adjust to new screen resolution
nitrogen --restore
