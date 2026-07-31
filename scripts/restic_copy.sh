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

REPO_NAME="${1:-restic-repo}"
MOUNT_DIR="/run/media/$USER"

discover_drives() {
    local -a drives=()
    local line rest mount_point label size
    while IFS= read -r line; do
        rest="${line#*MOUNTPOINT=\"}"; mount_point="${rest%%\"*}"
        rest="${line#*LABEL=\"}"; label="${rest%%\"*}"
        rest="${line#*SIZE=\"}"; size="${rest%%\"*}"
        case "$mount_point" in
            "$MOUNT_DIR"/*) drives+=("$label|$size|$mount_point") ;;
        esac
    done < <(lsblk -P -o MOUNTPOINT,LABEL,SIZE)
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

        # See restic_backup.sh for why --group-by '' is set.
        restic forget --prune --group-by '' \
          --keep-daily 5 --keep-weekly 3 --keep-monthly 4 --keep-yearly 3 -r "$TARGET_REPO"
        if [ $? -ne 0 ]; then
            echo "✗ Failed to prune $DRIVE_LABEL" | gum style --foreground 1 --align center --width 60
        fi
    done
fi
