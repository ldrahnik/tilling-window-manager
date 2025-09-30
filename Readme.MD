# Tilling Window Manager

[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fldrahnik%2Ftilling-window-manager&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)

Script works like a simple tilling window manager. Script uses `xdotool`, `wmctrl` and `xprop` (`x11-utils`). Shortcuts pointing to the script `tilling_window_manager.sh` have to be added manually, or for `gsettings` exists a prepared script `bash create_shortcuts.sh <directory with tilling_window_manager.sh - default is current working directory>`. Previously added shortcuts that would block newly added shortcuts are removed after confirmation, and no duplicates of custom shortcuts are created if the script is run again.

```
# using gsettings will be associated Super+[1-7], Super+Control+[1-7] and Control+[1-7]
$ bash create_shortcuts.sh
```

![Preview](preview_create_shortcuts.png)

![Preview](preview_shortcuts.png)
