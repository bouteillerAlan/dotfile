#!/usr/bin/env sh

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# `exec_once` can be run again after a Mango reload.  Starting a second awww
# daemon against its existing Wayland socket makes awww-daemon abort.
if ! awww query >/dev/null 2>&1; then
  awww-daemon --no-cache &
  # wait until the daemon is up
  for _ in $(seq 50); do
    awww query >/dev/null 2>&1 && break
    sleep 0.1
  done
fi

# launch notification daemon
dunst &
notify-send "Mango" "Starting"

# set power profile
powerprofilesctl set performance

# launch keyring and wallet
kwalletd6 &
if [ -x /usr/lib/polkit-kde-authentication-agent-1 ]; then
  /usr/lib/polkit-kde-authentication-agent-1 &
else
  printf '%s\n' 'Mango startup: polkit-kde-agent is not installed; no graphical polkit authentication agent was started.' >&2
fi

# launch input method to fix deadkeys on ghostty
fcitx5 -d &

# network manager applet
nm-applet &

# yank history for bemenu
if command -v cliphist >/dev/null 2>&1; then
  wl-paste --type text --watch cliphist store &
  wl-paste --type image --watch cliphist store &
else
  printf '%s\n' 'Mango startup: cliphist is not installed; clipboard history is disabled.' >&2
fi

# wallpaper
awww img --transition-type wipe --transition-step 90 --transition-fps 60 --transition-angle 30 /home/a2n/Nextcloud/photos/wallpaper/best/tyler-lastovich-ddLiNMqWAOM-unsplash.jpg

hypridle_config="$script_dir/hypridle.conf"
hypridle -c "$hypridle_config" &

# lil bit of delay because external monitors can take some time to show
sleep 2
"$script_dir"/weebar.sh &

# wallpaper/bar observer
# "$script_dir"/autowall.sh &

# personal software
# at the end to avoid some window to show
# like for nextcloud, because of no connection or else
easyeffects -w &
keepassxc &

sleep 5 # here to wait for the gpg password prompt
nextcloud &

# done!
notify-send "Mango" "Done"

"$@"
