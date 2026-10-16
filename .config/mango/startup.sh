#!/usr/bin/env sh

# set splash screen
awww-daemon --no-cache &
# wait until the daemon is up
for _ in $(seq 50); do
    awww query >/dev/null 2>&1 && break
    sleep 0.1
done
# awww img /home/a2n/Nextcloud/photos/wallpaper/best/tyler-lastovich-ddLiNMqWAOM-unsplash.jpg

# launch notification daemon
dunst &
notify-send "Mango" "Starting"

# set power profile
powerprofilesctl set performance

# launch keyring and wallet
kwalletd6 &
/usr/lib/polkit-kde-authentication-agent-1 &

# launch inout method to fix deadkeys on ghostty
fcitx5 -d &

# network manager applet
nm-applet &

# yank history for bemenu
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &

# switch to the real wallpaper
awww img --transition-type wipe --transition-step 90 --transition-fps 60 --transition-angle 30 /home/a2n/Nextcloud/photos/wallpaper/best/tyler-lastovich-ddLiNMqWAOM-unsplash.jpg

sleep 2

# open the bar
eww daemon && eww open-many bar-0 bar bar-2

# personal software
nextcloud &
keepassxc &
easyeffects -w &

# done!
notify-send "Mango" "Done"

"$@"
