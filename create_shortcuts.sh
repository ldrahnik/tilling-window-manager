#!/usr/bin/env bash

if [[ $(command -v apt-get 2>/dev/null) ]]; then
    sudo apt-get install wmctrl xdotool x11-utils
fi

FULL_HEIGHT_KEYS="<Super>"
TOP_HALF_OF_HEIGHT_KEYS="<Control>"
BOTTOM_HALF_OF_HEIGHT_KEYS="<Super><Control>"

declare -a __COMBOS__
for n in {1..7}; do
  __COMBOS__+=("${FULL_HEIGHT_KEYS}${n}")
  __COMBOS__+=("${TOP_HALF_OF_HEIGHT_KEYS}${n}")
  __COMBOS__+=("${BOTTOM_HALF_OF_HEIGHT_KEYS}${n}")
done

__unbind_conflicts__() {
  local combo="$1"
  while IFS= read -r line; do
    local schema key value
    schema="$(awk '{print $1}' <<<"$line")"
    key="$(awk '{print $2}' <<<"$line")"
    value="${line#* $key }"

    local clear_value
    if [[ "$value" =~ ^\[.*\]$ ]]; then
      clear_value="[]"
    else
      if gsettings range "$schema" "$key" 2>/dev/null | head -1 | grep -qi "string"; then
        clear_value="''"
      else
        clear_value="[]"
      fi
    fi

    gsettings set "$schema" "$key" "$clear_value" 2>/dev/null \
      && echo "Unbound $combo from $schema $key"
  done < <(gsettings list-recursively | grep -F -- "'$combo'")
}

echo "This script may unbind existing GNOME/elementary shortcuts for:"
printf '  %s\n' "${__COMBOS__[@]}"
read -rp "Do you want to unbind them if found? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  for c in "${__COMBOS__[@]}"; do
    __unbind_conflicts__ "$c"
  done
else
  echo "Skipping unbind step."
fi

get_custom_keybindings() {
    local keybindings
    keybindings=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

    if [[ "$keybindings" == "@as []" ]]; then
        echo ""
        return
    fi

    echo "$keybindings" \
        | sed -e "s/^@as \[\(.*\)\]$/\1/" \
              -e "s/\['//g" \
              -e "s/'\]//g" \
              -e "s/', '/\n/g"
}

get_keybinding_details() {
    local keybinding_path="$1"
    local command binding

    command=$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$keybinding_path command)
    binding=$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$keybinding_path binding)

    command=$(echo "$command" | sed "s/'//g")
    binding=$(echo "$binding" | sed "s/'//g")

    echo "$command $binding"
}

get_next_free_index() {
    local existing_indexes

    existing_indexes=$(get_custom_keybindings | sed -n 's:.*/custom\([0-9]\+\)/$:\1:p' | sort -n)

    local index=0
    for i in $existing_indexes; do
        if [ "$i" -ne "$index" ]; then
            break
        fi
        index=$((index + 1))
    done

    echo "$index"
}

# Function to create a new shortcut
create_shortcut() {
    local command="$1"
    local keys="$2"

    local existing_shortcut
    local keybinding_path
    local keybinding_exists=0

    # Loop over existing keybindings to check for duplicate command and binding
    for keybinding_path in $(get_custom_keybindings); do
        existing_shortcut=$(get_keybinding_details "$keybinding_path")
        if [[ "$existing_shortcut" == "$command $keys" ]]; then
            keybinding_exists=1
            break
        fi
    done

    if [ "$keybinding_exists" -eq 1 ]; then
        echo "Shortcut with command '$command' and binding '$keys' already exists. Skipping..."
        return
    fi

    local index
    index=$(get_next_free_index)
    
    local keybinding_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$index/"

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$index/ name "Tilling-window-manager shortcut"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$index/ command "$command"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$index/ binding "$keys"

    local current_keybindings
    current_keybindings=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

    if [[ "$current_keybindings" == "@as []" ]]; then
        updated_keybindings="['$keybinding_path']"
    else
        current_keybindings=${current_keybindings:1:-1}
        updated_keybindings="[$current_keybindings, '$keybinding_path']"
    fi

    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$updated_keybindings"
    
    echo "Shortcut created with keys '$keys' for command '$command'"
}



if [ "$#" -ne 1 ]; then
    SCRIPT_DIR=$(dirname "$(realpath "$0")")

    TILLING_WINDOW_MANAGER_SRC_DIR="$SCRIPT_DIR"
else
    TILLING_WINDOW_MANAGER_SRC_DIR="$1"
fi

if [ ! -f "$TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh" ]; then
    echo "Error: File 'tilling_window_manager.sh' not found in $TILLING_WINDOW_MANAGER_SRC_DIR"
    exit 1
fi

FULL_HEIGHT_KEYS="<Super>"
TOP_HALF_OF_HEIGHT_KEYS="<Control>"
BOTTOM_HALF_OF_HEIGHT_KEYS="<Super><Control>"

# 1
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 1280 1440 0 0" "${FULL_HEIGHT_KEYS}1"
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 1280 720 0 0" "${TOP_HALF_OF_HEIGHT_KEYS}1"
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 1280 720 0 720" "${BOTTOM_HALF_OF_HEIGHT_KEYS}1"

# 2
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 1280 1440 1280 0" "${FULL_HEIGHT_KEYS}2"
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 1280 720 1280 0" "${TOP_HALF_OF_HEIGHT_KEYS}2"
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 1280 720 1280 720" "${BOTTOM_HALF_OF_HEIGHT_KEYS}2"

# 3
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 1280 1440 2560 0" "${FULL_HEIGHT_KEYS}3"
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 1280 720 2560 0" "${TOP_HALF_OF_HEIGHT_KEYS}3"
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 1280 720 2560 720" "${BOTTOM_HALF_OF_HEIGHT_KEYS}3"

# 4
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 1280 1440 3840 0" "${FULL_HEIGHT_KEYS}4"
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 1280 720 3840 0" "${TOP_HALF_OF_HEIGHT_KEYS}4"
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 1280 720 3840 720" "${BOTTOM_HALF_OF_HEIGHT_KEYS}4"

# 5
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 2560 1440 1280 0" "${FULL_HEIGHT_KEYS}5"
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 2560 720 1280 0" "${TOP_HALF_OF_HEIGHT_KEYS}5"
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 2560 720 1280 720" "${BOTTOM_HALF_OF_HEIGHT_KEYS}5"

# 6
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 2560 1440 2560 0" "${FULL_HEIGHT_KEYS}6"
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 2560 720 2560 0" "${TOP_HALF_OF_HEIGHT_KEYS}6"
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 2560 720 2560 720" "${BOTTOM_HALF_OF_HEIGHT_KEYS}6"

# 7
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 2560 1440 0 0" "${FULL_HEIGHT_KEYS}7"
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 2560 720 0 0" "${TOP_HALF_OF_HEIGHT_KEYS}7"
create_shortcut "bash $TILLING_WINDOW_MANAGER_SRC_DIR/tilling_window_manager.sh 2560 720 0 720" "${BOTTOM_HALF_OF_HEIGHT_KEYS}7"
