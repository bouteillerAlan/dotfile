#!/usr/bin/env sh

# daemon for the topbar
eww daemon &

# set splash screen
awww-daemon --no-cache &
# wait until the daemon is up
# this is important for this one
for _ in $(seq 50); do
    awww query >/dev/null 2>&1 && break
    sleep 0.1
done

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

# idle daemon
hypridle &

# lil bit of delay because external monitors can take some time to show
sleep 2
/home/a2n/.config/mango/weebar.sh &

# wallpaper/bar observer
/home/a2n/.config/mango/autowall.sh &

# personal software
# at the end to avoid some window to show
# like for nextcloud, because of no connection or else
nextcloud &
keepassxc &
easyeffects -w &

# done!
notify-send "Mango" "Done"

"$@"
