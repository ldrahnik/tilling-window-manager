# Tilling Window Manager

Script works like a simple tilling window manager. Script uses `xdotool`, `wmctrl` and `xprop` (`x11-utils`). Shortcuts pointing to the script `tilling_window_manager.sh` have to be added manually, or for `gsettings` exists a prepared script `bash create_shortcuts.sh <directory with tilling_window_manager.sh - default is current working directory>`. Previously added shortcuts that would block newly added shortcuts are removed after confirmation, and no duplicates of custom shortcuts are created if the script is run again.

```
# using gsettings will be associated Super+[1-7], Super+Control+[1-7] and Control+[1-7]
$ bash create_shortcuts.sh
```

![Preview](preview_create_shortcuts.png)

![Preview](preview_shortcuts.png)
