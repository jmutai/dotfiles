#!/bin/bash
if [ -d /etc/X11/xinit/xinitrc.d ]; then
      for f in /etc/X11/xinit/xinitrc.d/*; do
              [ -x "$f" ] && . "$f"
                done
                  unset f
              fi

xset -b # turn off bell/beep volume; caja crucial

# exec i3  &>/dev/null
exec i3  &>/dev/null
#exec dwm

eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

