#!/usr/bin/env sh

# Start a program only when its process is not already running
start_once() {
  process_pattern=$1
  shift

  if ! pgrep -f -- "$process_pattern" >/dev/null 2>&1; then
    "$@" &
  fi
}

# set splash screen
start_once '(^|/)awww daemon( |$)' awww-daemon --no-cache
# wait until the daemon is up
# this is important for this one
for _ in $(seq 50); do
  awww query >/dev/null 2>&1 && break
  sleep 0.1
done

# launch notification daemon
start_once '(^|/)dunst( |$)' dunst
notify-send "Mango" "Starting"

# set power profile
powerprofilesctl set performance

# launch keyring and wallet
start_once '(^|/)kwalletd6( |$)' kwalletd6
start_once '(^|/)polkit-kde-authentication-agent-1( |$)' /usr/lib/polkit-kde-authentication-agent-1

# launch input method to fix deadkeys on ghostty
start_once '(^|/)fcitx5( |$)' fcitx5 -d

# network manager applet
start_once '(^|/)nm-applet( |$)' nm-applet

# yank history for bemenu
start_once '(^|/)wl-paste --type text --watch cliphist store$' wl-paste --type text --watch cliphist store
start_once '(^|/)wl-paste --type image --watch cliphist store$' wl-paste --type image --watch cliphist store

# switch to the real wallpaper
awww img --transition-type wipe --transition-step 90 --transition-fps 60 --transition-angle 30 /home/a2n/Nextcloud/photos/wallpaper/best/tyler-lastovich-ddLiNMqWAOM-unsplash.jpg

# idle daemon
start_once '(^|/)hypridle( |$)' hypridle

# lil bit of delay because external monitors can take some time to show
sleep 2
./home/a2n/.config/mango/weebar.sh &

# wallpaper/bar observer
start_once '(^|/)autowall.sh( |$)' ./home/a2n/.config/mango/autowall.sh

# personal software
# at the end to avoid some window to show
# like for nextcloud, because of no connection or else
start_once '(^|/)nextcloud( |$)' nextcloud
start_once '(^|/)keepassxc( |$)' keepassxc
start_once '(^|/)easyeffects( |$)' easyeffects -w

# done!
notify-send "Mango" "Done"

"$@"
