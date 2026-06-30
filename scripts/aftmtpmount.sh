#!/usr/bin/env bash

# Android device mounting

echo "Before running this, plug in the device and enable 'File transfer'."
echo "It might also require 'Allow USB Debugging'."

mkdir -p ~/android_mount
if mountpoint -q ~/android_mount; then
    fusermount -u ~/android_mount && echo "Unmounted" || echo "Unmount failed"
else
    aft-mtp-mount ~/android_mount && echo "Mounted" || echo "Mount failed"
fi
