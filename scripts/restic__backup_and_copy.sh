#!/usr/bin/env bash

# Orchestrates my restic_backup.sh and restic_copy.sh wrapper scripts.

# Requires:
#   gum
#   restic
#   restic_backup.sh in same directory
#   restic_copy.sh in same directory

cleanup() {
    unset RESTIC_PASSWORD
    unset RESTIC_FROM_PASSWORD
}
trap cleanup EXIT

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPTS_DIR/restic_copy.sh"
readarray -t DRIVES < <(discover_drives)

if [ ${#DRIVES[@]} -gt 0 ]; then
    echo "Will copy to ${#DRIVES[@]} USB drive(s):" | gum style --foreground 6
    for drive_info in "${DRIVES[@]}"; do
        IFS='|' read -r label size mount_point <<< "$drive_info"
        echo "  - $label ($size) at $mount_point" | gum style --foreground 6
    done
    echo
fi

echo "Enter the restic repository password for both source and target repositories:" | gum style --foreground 6
read -s -r RESTIC_PASSWORD
export RESTIC_PASSWORD
export RESTIC_FROM_PASSWORD="$RESTIC_PASSWORD"

"$SCRIPTS_DIR/restic_backup.sh" || exit 1
echo ""
echo "Copying to drive..."
echo ""
[ ${#DRIVES[@]} -gt 0 ] && "$SCRIPTS_DIR/restic_copy.sh"
