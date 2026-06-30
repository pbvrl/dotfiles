#!/usr/bin/env bash

# Monitor for, and automount drives with recognized serials.
# https://mikejsavage.co.uk/nixos-auto-mounting/
# https://wiki.archlinux.org/title/Udisks#udevadm_monitor

# NOTE: For convenience. For security look into USBGuard.

# AUTOMOUNTABLE_SERIALS=(
#     "xxxxxxxxxxxxxxxx"
#     "xxxxxxxxxxxxxxxx"
# )
mapfile -t AUTOMOUNTABLE_SERIALS < "$AUTOMOUNTABLE_SERIALS_FILE"

mount() {
    local devpath=$1
    local props=$(udevadm info --path="$devpath" --query=property)

    local fs_type=$(echo "$props" | grep -oP '(?<=^ID_FS_TYPE=).*')
    [ -n "$fs_type" ] || return 0 # Only mount if it has a filesystem

    local serial=$(echo "$props" | grep -oP '(?<=^ID_SERIAL_SHORT=).*')
    local devname=$(echo "$props" | grep -oP '(?<=^DEVNAME=).*')

    local mount_opts="nodev,nosuid,noexec"
    if [[ "$fs_type" =~ ^(vfat|exfat|ntfs)$ ]]; then
        mount_opts="${mount_opts},uid=${USER_UID}"
    fi
    for automountable_serial in "${AUTOMOUNTABLE_SERIALS[@]}"; do
        if [ "$serial" = "$automountable_serial" ]; then
            if udisksctl mount --block-device "$devname" --no-user-interaction --options "$mount_opts"; then
                notify-send -c minimal "" "Recognized device. Mounted"
            fi
            break
        fi
    done
}

# Check first for already plugged in devices
for devpath in /sys/class/block/*; do
    [ -e "$devpath" ] || continue
    mount "$devpath"
done
# Monitor for when a device is plugged in
stdbuf -oL -- udevadm monitor --udev -s block | while read -r -- _ _ event devpath _; do
    if [ "$event" = "add" ]; then
        mount "$devpath"
    fi
done
