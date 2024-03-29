#!/usr/bin/env bash

# requirements: sudo apt-get install wmctrl xdotool
# debugging: xprop xwininfo
# example of usage (is described how to use script for split windows to 1/2, 1/4 and 1/8 on ultra width monitor with resolution 5120x1440 - so 2 rows and 4 columns):
#
#           bash ./script.sh 2560 1440 0 0 - 1st 1/2
#           (
#                 bash ./script.sh 1280 1440 0 0 - 1st 1/4
#                 (
#                       bash ./script.sh 1280 720 0 0 - 1st lower 1/8
#                       bash ./script.sh 1280 720 0 720 - 1st upper 1/8
#                 )
#                 bash ./script.sh 1280 1440 1280 0 - 2nd 1/4
#                 bash ./script.sh 1280 1440 2560 0 - 3rd 1/4
#                 bash ./script.sh 1280 1440 3840 0 - 4th 1/4
#           )

# get active window
# debugging: getactivewindow -> selectwindow
ACTIVE_WINDOW_ID=$(xdotool getactivewindow)

# un-maximize
#ACTIVE_WINDOW_HORZ_MAX=$(xprop -id "$ACTIVE_WINDOW_ID" _NET_WM_STATE | grep '_NET_WM_STATE_MAXIMIZED_HORZ')
#ACTIVE_WINDOW_HORY_MAX=$(xprop -id "$ACTIVE_WINDOW_ID" _NET_WM_STATE | grep '_NET_WM_STATE_MAXIMIZED_VERT')
#if [[ "$ACTIVE_WINDOW_HORZ_MAX" || "$ACTIVE_WINDOW_HORY_MAX" ]]; then
#   wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
#fi
wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz

# take into account borders & workarea dimmensions
NET_FRAME_EXTENTS=$(xprop -id $ACTIVE_WINDOW_ID | grep _NET_FRAME_EXTENTS | cut -d '=' -f 2 | tr -d ' ')
echo "NET_FRAME_EXTENTS: $NET_FRAME_EXTENTS"

NET_FRAME_EXTENTS_LEFT=0
NET_FRAME_EXTENTS_RIGHT=0
NET_FRAME_EXTENTS_TOP=0
NET_FRAME_EXTENTS_BOTTOM=0
if [ "$NET_FRAME_EXTENTS" ];
then
    NET_FRAME_EXTENTS_LEFT=$(echo $NET_FRAME_EXTENTS | cut -d ',' -f 1)
    NET_FRAME_EXTENTS_RIGHT=$(echo $NET_FRAME_EXTENTS | cut -d ',' -f 2)
    NET_FRAME_EXTENTS_TOP=$(echo $NET_FRAME_EXTENTS | cut -d ',' -f 3)
    NET_FRAME_EXTENTS_BOTTOM=$(echo $NET_FRAME_EXTENTS | cut -d ',' -f 4)
fi

GTK_FRAME_EXTENTS=$(xprop -id $ACTIVE_WINDOW_ID | grep _GTK_FRAME_EXTENTS | cut -d '=' -f 2 | tr -d ' ')
echo "GTK_FRAME_EXTENTS: $GTK_FRAME_EXTENTS"

GTK_FRAME_EXTENTS_LEFT=0
GTK_FRAME_EXTENTS_RIGHT=0
GTK_FRAME_EXTENTS_TOP=0
GTK_FRAME_EXTENTS_BOTTOM=0
if [ "$GTK_FRAME_EXTENTS" ];
then
    GTK_FRAME_EXTENTS_LEFT=$(echo $GTK_FRAME_EXTENTS | cut -d ',' -f 1)
    GTK_FRAME_EXTENTS_RIGHT=$(echo $GTK_FRAME_EXTENTS | cut -d ',' -f 2)
    GTK_FRAME_EXTENTS_TOP=$(echo $GTK_FRAME_EXTENTS | cut -d ',' -f 3)
    GTK_FRAME_EXTENTS_BOTTOM=$(echo $GTK_FRAME_EXTENTS | cut -d ',' -f 4)
fi

eval "$(wmctrl -d | grep '*' | sed -n -E -e 's/^.*WA: ([0-9]+),([0-9]+) ([0-9]+)x([0-9]+).*$/WA_X=\1;WA_Y=\2;WA_W=\3;WA_H=\4/p')"

# change size & position
NEW_POS_X=$(($3 - $GTK_FRAME_EXTENTS_LEFT + $NET_FRAME_EXTENTS_LEFT))
NEW_POS_Y=$(($4 - $GTK_FRAME_EXTENTS_TOP + $NET_FRAME_EXTENTS_TOP))
NEW_SIZE_X=$(($1 + $GTK_FRAME_EXTENTS_LEFT + $GTK_FRAME_EXTENTS_RIGHT - $NET_FRAME_EXTENTS_LEFT - $NET_FRAME_EXTENTS_RIGHT - $WA_X))
NEW_SIZE_Y=$(($2 + $GTK_FRAME_EXTENTS_TOP + $GTK_FRAME_EXTENTS_BOTTOM - $NET_FRAME_EXTENTS_TOP - $NET_FRAME_EXTENTS_BOTTOM))

if (( $4 < $WA_Y ));
then
    echo "WA_Y $WA_Y subtrackted"
    NEW_SIZE_Y=$(($NEW_SIZE_Y - $WA_Y))
fi

# debugging: getactivewindow -> selectwindow
echo "New size and position: $NEW_SIZE_X $NEW_SIZE_Y $NEW_POS_X $NEW_POS_Y"
xdotool getactivewindow windowsize "$NEW_SIZE_X" "$NEW_SIZE_Y" windowmove -- "$NEW_POS_X" "$NEW_POS_Y"
