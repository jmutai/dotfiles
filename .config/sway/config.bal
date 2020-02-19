input * xkb_layout dvorak_ger_io
input * xkb_options lv3:ralt_switch
input "7847:2311:SEMITEK_USB-HID_Gaming_Keyboard" xkb_options lv3:switch

seat * hide_cursor 2000

exec_always ~/.config/dots/monitor.sh
exec_always ~/.config/wallpaper/set

set $gnome-schema org.gnome.desktop.interface

exec_always gsettings set $gnome-schema gtk-theme 'Arc-Dark'

set $bg-color            #333333
set $inactive-bg-color   #333333
set $text-color          #f3f4f5
set $inactive-text-color #676E7D
set $urgent-bg-color     #E53935
set $focus-text-color     #87CEEB

set $black       #282828
set $darkblack   #1d2021
set $transparent #000000AA

default_border none
smart_gaps on
gaps outer 0
gaps inner 1

# Please see http://i3wm.org/docs/userguide.html for a complete reference!

set $mod Mod4

# Font for window titles. Will also be used by the bar unless a different font
# is used in the bar {} block below.
#font pango:System San Francisco Display 10 

font pango: Inconsolata 12

# This font is widely installed, provides lots of unicode glyphs, right-to-left
# text rendering and scalability on retina/hidpi displays (thanks to pango).
#font pango:DejaVu Sans Mono 8

# Before i3 v4.8, we used to recommend this one as the default:
# font -misc-fixed-medium-r-normal--13-120-75-75-C-70-iso10646-1
# The font above is very space-efficient, that is, it looks good, sharp and
# clear in small sizes. However, its unicode glyph coverage is limited, the old
# X core fonts rendering does not support right-to-left and this being a bitmap
# font, it doesn’t scale on retina/hidpi displays.

# Use Mouse+$mod to drag floating windows to their wanted position
floating_modifier $mod

# start a terminal
bindsym $mod+Return exec urxvt

# kill focused window
bindsym $mod+Shift+question kill

bindsym Print exec screenshot

# start dmenu (a program launcher)
#bindsym $mod+e exec dmenu_run
bindsym $mod+e exec rofi -show run -lines 5 -eh 1 -width 30 -padding 30 -opacity "75" -bw 0 -bc $bg-color -bg $bg-color -fg $text-color -hlbg $bg-color -hlfg #9575cd -font "System San Francisco Display 10"

# There also is the (new) i3-dmenu-desktop which only displays applications
# shipping a .desktop file. It is a wrapper around dmenu, so you need that
# installed.
# bindsym $mod+d exec --no-startup-id i3-dmenu-desktop

# change focus
bindsym $mod+d focus left
bindsym $mod+r focus down
bindsym $mod+n focus up
bindsym $mod+s focus right

# alternatively, you can use the cursor keys:
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

# move focused window
bindsym $mod+Shift+d move left
bindsym $mod+Shift+r move down
bindsym $mod+Shift+n move up
bindsym $mod+Shift+s move right

# alternatively, you can use the cursor keys:
bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right

# split in horizontal orientation
bindsym $mod+h split h

# split in vertical orientation
bindsym $mod+k split v

# enter fullscreen mode for the focused container
bindsym $mod+i fullscreen toggle

# change container layout (stacked, tabbed, toggle split)
bindsym $mod+o layout stacking
bindsym $mod+comma layout tabbed
bindsym $mod+period layout toggle split

# toggle tiling / floating
bindsym $mod+Shift+space floating toggle

# change focus between tiling / floating windows
bindsym $mod+space focus mode_toggle

# focus the parent container
bindsym $mod+a focus parent

# focus the child container
#bindsym $mod+d focus child

set $ws1 "1 "
set $ws2 "2 "
set $ws3 "3 "
set $ws4 "4 "
set $ws5 "5 "
set $ws6 "6 "
set $ws7 "7 "
set $ws8 "8 ♪"
set $ws9 "9 "
set $ws10 "10 ☕"
set $ws11 "F1"
set $ws12 "F2"
set $ws13 "F3"
set $ws14 "F4"
set $ws15 "F5"
set $ws16 "F6"
set $ws17 "F7"
set $ws18 "F8"
set $ws19 "F9"
set $ws20 "F10"

# switch to workspace
bindsym $mod+1 workspace $ws1
bindsym $mod+2 workspace $ws2
bindsym $mod+3 workspace $ws3
bindsym $mod+4 workspace $ws4
bindsym $mod+5 workspace $ws5
bindsym $mod+6 workspace $ws6
bindsym $mod+7 workspace $ws7
bindsym $mod+8 workspace $ws8
bindsym $mod+9 workspace $ws9
bindsym $mod+0 workspace $ws10
bindsym $mod+F1 workspace $ws11
bindsym $mod+F2 workspace $ws12
bindsym $mod+F3 workspace $ws13
bindsym $mod+F4 workspace $ws14
bindsym $mod+F5 workspace $ws15
bindsym $mod+F6 workspace $ws16
bindsym $mod+F7 workspace $ws17
bindsym $mod+F8 workspace $ws18
bindsym $mod+F9 workspace $ws19
bindsym $mod+F10 workspace $ws20

# move focused container to workspace
bindsym $mod+Shift+1 move container to workspace $ws1
bindsym $mod+Shift+2 move container to workspace $ws2
bindsym $mod+Shift+3 move container to workspace $ws3
bindsym $mod+Shift+4 move container to workspace $ws4
bindsym $mod+Shift+5 move container to workspace $ws5
bindsym $mod+Shift+6 move container to workspace $ws6
bindsym $mod+Shift+7 move container to workspace $ws7
bindsym $mod+Shift+8 move container to workspace $ws8
bindsym $mod+Shift+9 move container to workspace $ws9
bindsym $mod+Shift+0 move container to workspace $ws10
bindsym $mod+Shift+F1 move container to workspace $ws11
bindsym $mod+Shift+F2 move container to workspace $ws12
bindsym $mod+Shift+F3 move container to workspace $ws13
bindsym $mod+Shift+F4 move container to workspace $ws14
bindsym $mod+Shift+F5 move container to workspace $ws15
bindsym $mod+Shift+F6 move container to workspace $ws16
bindsym $mod+Shift+F7 move container to workspace $ws17
bindsym $mod+Shift+F8 move container to workspace $ws18
bindsym $mod+Shift+F9 move container to workspace $ws19
bindsym $mod+Shift+F10 move container to workspace $ws20

exec_always ~/.config/waybar/init
bindsym $mod+j exec ~/.config/waybar/toggle

# move current workspace between monitors
bindsym $mod+Control+d move workspace to output left
bindsym $mod+Control+s move workspace to output right

workspace_auto_back_and_forth yes

#assign [class="dolphin"] $ws9
assign [class="Spotify"] $ws10

# reload the configuration file
bindsym $mod+Shift+p exec ~/.config/sway/setup && swaymsg reload

# exit i3 (logs you out of your X session)
#bindsym $mod+Shift+period exec swaynag -t warning -m 'Byeeeeeeeeeeeez?!?!' -b 'Cya!' 'swaymsg exit'

set $suspend ~/.bin/lock.sh && sleep 5 && ~/.bin/suspend
set $mode_system System: (l) lock, (e) logout, (s) suspend, (R) reboot, (P) poweroff, (U) UEFI
mode "$mode_system" {
        bindsym l exec notif 'locking' & ~/.bin/lock.sh, mode "default"
        bindsym e exit
        bindsym s exec notif 'suspending' & $suspend, mode "default"
        bindsym Shift+r exec reboot
        bindsym Shift+p exec poweroff
        bindsym Shift+u exec systemctl reboot --firmware-setup, mode "default"

        # return to default mode
        bindsym Return mode "default"
        bindsym Escape mode "default"
}

bindsym $mod+l exec notif 'locking' & ~/.bin/lock.sh
bindsym $mod+Shift+l exec notif 'suspending' & $suspend
bindsym $mod+Shift+period mode "$mode_system"

exec swayidle -w \
         timeout 90 'idle_handler.sh' \
         resume 'swaymsg "output * dpms on"'

# resize window (you can also use the mouse for that)
mode "resize" {
        # These bindings trigger as soon as you enter the resize mode

        # Pressing left will shrink the window’s width.
        # Pressing right will grow the window’s width.
        # Pressing up will shrink the window’s height.
        # Pressing down will grow the window’s height.
        bindsym d resize shrink width 10 px or 5 ppt
        bindsym r resize grow height 10 px or 5 ppt
        bindsym n resize shrink height 10 px or 5 ppt
        bindsym s resize grow width 10 px or 5 ppt

        bindsym Shift+d resize shrink width 30 px or 15 ppt
        bindsym Shift+r resize grow height 30 px or 15 ppt
        bindsym Shift+n resize shrink height 30 px or 15 ppt
        bindsym Shift+s resize grow width 30 px or 15 ppt

        # same bindings, but for the arrow keys
        bindsym Left resize shrink width 10 px or 5 ppt
        bindsym Down resize grow height 10 px or 5 ppt
        bindsym Up resize shrink height 10 px or 5 ppt
        bindsym Right resize grow width 10 px or 5 ppt

        bindsym Shift+Left resize shrink width 30 px or 15 ppt
        bindsym Shift+Down resize grow height 30 px or 15 ppt
        bindsym Shift+Up resize shrink height 30 px or 15 ppt
        bindsym Shift+Right resize grow width 30 px or 15 ppt

        # back to normal: Enter or Escape
        bindsym Return mode "default"
        bindsym Escape mode "default"
}

bindsym $mod+p mode "resize"

hide_edge_borders both

# Make the currently focused window a scratchpad
#bindsym $mod+Shift+minus move scratchpad

# Show the first scratchpad window
#bindsym $mod+minus scratchpad show

bindsym $mod+Shift+z exec swaynag -t warning -m 'Sleepy time?!?!' -b 'ZzZz...' 'systemctl hibernate'

# Pulse Audio controls
bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume 0 +5% #increase sound volume
bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume 0 -5% #decrease sound volume
bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute 0 toggle # mute sound

# Sreen brightness controls
bindsym XF86MonBrightnessUp exec light -A 20 # increase screen brightness
bindsym XF86MonBrightnessDown exec light -U 20 # decrease screen brightness

# Touchpad controls
bindsym XF86TouchpadToggle exec /some/path/toggletouchpad.sh # toggle touchpad

# Media player controls
bindsym XF86AudioPlay exec playerctl play
bindsym XF86AudioPause exec playerctl pause
bindsym XF86AudioNext exec playerctl next
bindsy XF86AudioPrev exec playerctl previous

bindsym $mod+g exec grim -g "$(slurp)" screenshot_`date +%F_%HH%MM%SS`.png
bindsym $mod+c exec grim screenshot_`date +%F_%HH%MM%SS`.png

bindsym $mod+Shift+bar exec pactl set-sink-volume @DEFAULT_SINK@ -2%
bindsym $mod+Shift+q exec pactl set-sink-volume @DEFAULT_SINK@ +2%

bindsym $mod+bar exec --no-startup-id cmuspoti_prev
bindsym $mod+q exec --no-startup-id cmuspoti_next

bindsym $mod+question exec --no-startup-id cmuspoti_play

bindsym $mod+t exec light -U 20
bindsym $mod+z exec light -A 20

bindsym $mod+minus exec kb-light.py -
bindsym $mod+slash exec kb-light.py +

bindsym $mod+w exec pick_wallpaper
bindsym $mod+Shift+w exec randomize_wallpaper

bindsym $mod+f exec clipman -s --max-items=15 --selector="rofi"
bindsym $mod+Shift+f exec clipmand --max-items=30

bindsym $mod+x exec pass_rofi

bar {
  swaybar_command waybar
}

no_focus [window_role="pop-up"]

for_window [class="^.*"] border pixel 0

for_window [class="(?i)Enpass"] floating enable, move position mouse
for_window [class="(?i)pavucontrol"] floating enable, move position mouse
for_window [class="(?i)pavucontrol" instance="pavucontrol-bar"] move down 34px
for_window [class="(?i)Veracrypt"] floating enable, move position mouse
for_window [class="(?i)calc"] floating enable, move position mouse

exec nm-applet --indicator
exec clipmand --max-items=30
#exec redshift -m wayland -l 53.55:9.993
exec urxvt -e ghsync
exec flashfocus
