#!/usr/bin/env sh

apply_wallpaper() {
  awww img --transition-type wipe --transition-step 90 --transition-fps 60 --transition-angle 30 /home/a2n/Nextcloud/photos/wallpaper/best/tyler-lastovich-ddLiNMqWAOM-unsplash.jpg
}

udevadm monitor --udev --property --subsystem-match=drm |
  while IFS= read -r property; do
    [ "$property" = "ACTION=change" ] || continue
    sleep 1
    apply_wallpaper # apply wallpaper
    /home/a2n/.config/mango/weebar.sh # pop a bar
  done

"$@"
