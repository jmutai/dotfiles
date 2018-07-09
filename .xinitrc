#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)
# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK
xrdb -merge ~/.Xresources

#export SSH_ASKPASS=ssh-askpass

#xrandr --dpi 144
#xrandr --fbmm 209x209

#exec i3 --shmlog-size 0
exec i3


