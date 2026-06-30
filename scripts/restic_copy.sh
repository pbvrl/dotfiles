#!/usr/bin/env bash

# TODO: Check for security hazards.

# 1. Checks for mounted drives at $MOUNT_DIR.
# For each drive at $MOUNTPOINT=$MOUNT_DIR/*:
#    2. Checks for available space. If little, prompts for confirmation.
#    3. Checks for the target repo. If not there, asks to create it.
#    4. Runs "restic copy" from $HOME/$REPO_NAME to $MOUNTPOINT/$REPO_NAME.
#    5. Prunes old backups from $MOUNTPOINT/$REPO_NAME.

# Requires:
#   gum
#   restic

REPO_NAME="restic-repo"
MOUNT_DIR="/run/media/$USER"

discover_drives() {
    local mounted_paths=$(lsblk -o MOUNTPOINT -n | grep "^$MOUNT_DIR" || true)
    local -a drives=()
    if [ -n "$mounted_paths" ]; then
        while IFS= read -r mount_point; do
            local label=$(lsblk -o MOUNTPOINT,LABEL,SIZE -n | grep "^$mount_point" | awk '{print $2}')
            local size=$(lsblk -o MOUNTPOINT,SIZE -n | grep "^$mount_point" | awk '{print $2}')
            drives+=("$label|$size|$mount_point")
        done <<< "$mounted_paths"
    fi
    printf '%s\n' "${drives[@]}"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then

    readarray -t DRIVES < <(discover_drives)
    echo "Found ${#DRIVES[@]} mounted drive(s):" | gum style --foreground 6
    for drive_info in "${DRIVES[@]}"; do
        IFS='|' read -r label size mount_point <<< "$drive_info"
        echo "  - $label ($size) at $mount_point" | gum style --foreground 6
    done
    echo

    SOURCE_REPO="$HOME/$REPO_NAME"
    SOURCE_SIZE=$(du -sk "$SOURCE_REPO" | awk '{print $1}')

    for drive_info in "${DRIVES[@]}"; do
        IFS='|' read -r DRIVE_LABEL _ MOUNTPOINT <<< "$drive_info"
        TARGET_REPO="$MOUNTPOINT/$REPO_NAME"

        TARGET_FREE=$(df -k "$MOUNTPOINT" | tail -1 | awk '{print $4}')
        if (( TARGET_FREE < SOURCE_SIZE )); then
            echo "Warning: $DRIVE_LABEL may not have enough space." | gum style --foreground 3
            if ! gum confirm "Continue with $DRIVE_LABEL anyway?"; then
                echo "Skipping $DRIVE_LABEL." | gum style --foreground 3
                continue
            fi
        fi

        restic -r "$TARGET_REPO" cat config &>/dev/null
        if [ $? -eq 10 ]; then
            if gum confirm "Initialize restic repository on $DRIVE_LABEL?"; then
                echo "Initializing $TARGET_REPO" | gum style --foreground 6
                restic init --copy-chunker-params --from-repo "$SOURCE_REPO" -r "$TARGET_REPO"
                chown "$USER":users "$TARGET_REPO"
            else
                echo "Skipping $DRIVE_LABEL." | gum style --foreground 3
                continue
            fi
        fi

        restic copy --from-repo "$SOURCE_REPO" --repo "$TARGET_REPO"
        if [ $? -ne 0 ]; then
            echo "✗ Failed to copy to $DRIVE_LABEL" | gum style --foreground 1 --border double --align center --width 60
            continue
        fi

        restic forget --prune --keep-daily 3 --keep-weekly 3 --keep-yearly 1 -r "$TARGET_REPO"
        if [ $? -ne 0 ]; then
            echo "✗ Failed to prune $DRIVE_LABEL" | gum style --foreground 1 --align center --width 60
        fi
    done
fi
