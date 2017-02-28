#!/bin/bash
if [ -d /etc/X11/xinit/xinitrc.d ]; then
      for f in /etc/X11/xinit/xinitrc.d/*; do
              [ -x "$f" ] && . "$f"
                done
                  unset f
              fi

xset -b # turn off bell/beep volume; caja crucial

# exec i3  &>/dev/null
export SSH_ASKPASS=ssh-askpass
exec i3  &>/dev/null
#exec dwm
