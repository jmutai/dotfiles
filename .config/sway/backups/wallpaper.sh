#!/usr/bin/env bash

WALLPATH=~/Pictures/wallpaper/

# Terminate already running bar instances
killall -q swaybg

# Wait until the processes have been shut down
while pgrep -u $UID -x swaybg >/dev/null; do
	sleep 1
done

swaybg --output '*' --mode fill --image "$(find ${WALLPATH}|shuf|head -n 1)"
