#!/bin/sh
notif=$(cat .config/dots/notification)
echo -e "{\"text\":\""$notif"\", \"class\":\"""\"}"
