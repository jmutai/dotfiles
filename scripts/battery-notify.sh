#!/bin/env bash

# Battery notifier script for i3
# First warning is at 25%,  Second at 15%, and sleep below 10%
# By NerdJK23
# www.computingforgeeks.com
# kiplangatmtai@gmail.com

# Packages that should be installed are libnotify and acpi 
# pacman -S acpi libnotify > Arch Linux

# Some variables
full_level=100
low_level=25
very_low_level=15
critical_level=10
discharge_mode=`acpi -a | grep -o off` # a, --ac-adapter         ac adapter information

# Get current battery lavel 
battery_level=$(cat /sys/class/power_supply/BAT0/capacity)

# battery_level=$(acpi -b | sed 's/.*[dg], //g;s/\%,.*//g') # b, --battery battery information
# battery_level=`acpi -b | cut -d ' ' -f 4 | grep -o '[0-9]*'`

# Messages to print to notification
m1="*** Battery level is ${battery_level}, consider connecting a charger! ***"
m2="*** Battery level is ${battery_level}, Please charge!! ***"
m3="*** Battery level is ${battery_level}, critical, sleeping in 30 seconds time ***"

# Notification icon to use
not_icon="/usr/share/icons/gnome/scalable/status/battery-low-symbolic.svg" 


while true
do
    if [ "$discharge_mode" != "off" ]; then
        exit 11
    fi
# If battery is 100%
if [ "battery_level" == "full_level" ]; then
    notify-send -u normal -t 5000 " ***** Battery fully charged ****"
fi

case $battery_level in
    $low_level)
    notify-send -u critical -t 5000  $m1
    ;;

$very_low_level)
    if [ -f "$not_icon" ]; then
        notify-send -u critical -i "$not_icon" -t 30000 "$m2"
    else
        notify-send -u critical  -t 10000 "$m2"
    fi
    ;;

$critical_level)
    if [ -f "$not_icon" ]; then
        notify-send -u critical -i "$not_icon" -t 30000 "$m3"
        # /usr/bin/i3-nagbar -m "$(echo $MESSAGE)"
        sleep 30
        systemctl hybrid-sleep 

    else
        notify-send -u critical  -t 10000 "$m3"
        sleep 30
        systemctl hybrid-sleep 
    fi
    ;;
    esac
done

